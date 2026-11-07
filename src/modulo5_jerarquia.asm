; ==========================================================
; LOWMONITOR - MODULO 5
; GESTION JERARQUICA DE MEMORIA
; VERSION 3 - ACCESOS ALEATORIOS DEPENDIENTES
;
; Arquitectura: x86-64
; Sistema: Linux
; Ensamblador: NASM
;
; Mediciones experimentales en ciclos por acceso.
; ==========================================================

default rel

%define ITERACIONES 1000000
%define REPETICIONES 5
%define BUFFER_SIZE 67108864
%define LINEA_CACHE 64
%define MAX_LINEAS (BUFFER_SIZE / LINEA_CACHE)

section .data

titulo:
    db 10
    db "========================================", 10
    db " LOWMONITOR - MODULO 5", 10
    db " JERARQUIA DE MEMORIA - VERSION 3", 10
    db "========================================", 10

titulo_len equ $ - titulo

msg_reg:
    db 10, "Registros: "
msg_reg_len equ $ - msg_reg

msg_l1:
    db "Cache L1 (16 KiB): "
msg_l1_len equ $ - msg_l1

msg_l2:
    db "Cache L2 (256 KiB): "
msg_l2_len equ $ - msg_l2

msg_l3:
    db "Cache L3 (8 MiB): "
msg_l3_len equ $ - msg_l3

msg_ram:
    db "Memoria grande (64 MiB): "
msg_ram_len equ $ - msg_ram

msg_ciclos:
    db " ciclos minimos observados por acceso", 10
msg_ciclos_len equ $ - msg_ciclos

msg_fin:
    db 10, "Pruebas finalizadas.", 10
msg_fin_len equ $ - msg_fin

section .bss

align 64
buffer:
    resb BUFFER_SIZE

align 16
indices:
    resd MAX_LINEAS

numero:
    resb 32

section .text

global modulo5_main

modulo5_main:

    ; Preservar registros del programa principal
    push rbx
    push r12
    push r13
    push r14
    push r15

    lea rsi, [titulo]
    mov edx, titulo_len
    call imprimir

    ; ====================================
    ; PRUEBA DE REGISTROS
    ; ====================================

    lea rsi, [msg_reg]
    mov edx, msg_reg_len
    call imprimir

    mov ecx, ITERACIONES
    xor r8, r8

    lfence
    rdtsc

    shl rdx, 32
    or rax, rdx
    mov r12, rax

.registros:

    add r8, 1

    dec ecx
    jnz .registros

    rdtscp
    lfence

    shl rdx, 32
    or rax, rdx

    sub rax, r12

    xor edx, edx
    mov ecx, ITERACIONES
    div rcx

    call imprimir_numero

    ; ====================================
    ; PRUEBA CACHE L1
    ; ====================================

    lea rsi, [msg_l1]
    mov edx, msg_l1_len
    call imprimir

    mov rdi, 16384
    call medir_memoria

    ; ====================================
    ; PRUEBA CACHE L2
    ; ====================================

    lea rsi, [msg_l2]
    mov edx, msg_l2_len
    call imprimir

    mov rdi, 262144
    call medir_memoria

    ; ====================================
    ; PRUEBA CACHE L3
    ; ====================================

    lea rsi, [msg_l3]
    mov edx, msg_l3_len
    call imprimir

    mov rdi, 8388608
    call medir_memoria

    ; ====================================
    ; PRUEBA MEMORIA GRANDE
    ; ====================================

    lea rsi, [msg_ram]
    mov edx, msg_ram_len
    call imprimir

    mov rdi, BUFFER_SIZE
    call medir_memoria

    ; ====================================
    ; FINALIZAR
    ; ====================================

    lea rsi, [msg_fin]
    mov edx, msg_fin_len
    call imprimir

    ; Restaurar registros y regresar al menu
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx

    ret


; ==========================================================
; MEDICION DE MEMORIA
;
; Entrada:
; RDI = tamano del conjunto de datos
;
; Metodo:
; 1. Crear indices.
; 2. Mezclarlos con Fisher-Yates.
; 3. Construir una cadena circular.
; 4. Calentar el conjunto de datos.
; 5. Medir cinco veces.
; ==========================================================

medir_memoria:

    ; Numero de lineas de cache

    mov r14, rdi
    shr r14, 6

    lea rbx, [buffer]
    lea rsi, [indices]

    ; ====================================
    ; INICIALIZAR INDICES
    ; ====================================

    xor rcx, rcx

.inicializar:

    mov [rsi + rcx*4], ecx

    inc rcx
    cmp rcx, r14
    jb .inicializar

    ; ====================================
    ; MEZCLAR INDICES
    ; Fisher-Yates + Xorshift32
    ; ====================================

    mov r10d, 2463534242

    mov rcx, r14
    dec rcx

.mezclar:

    ; Generador pseudoaleatorio

    mov eax, r10d

    mov edx, eax
    shl edx, 13
    xor eax, edx

    mov edx, eax
    shr edx, 17
    xor eax, edx

    mov edx, eax
    shl edx, 5
    xor eax, edx

    mov r10d, eax

    ; j = aleatorio % (i + 1)

    xor edx, edx

    mov r11d, ecx
    inc r11d

    div r11d

    ; Intercambiar indices[i] e indices[j]

    mov eax, [rsi + rcx*4]
    mov r8d, [rsi + rdx*4]

    mov [rsi + rcx*4], r8d
    mov [rsi + rdx*4], eax

    dec rcx
    jnz .mezclar

    ; ====================================
    ; CONSTRUIR CADENA CIRCULAR
    ; ====================================

    xor rcx, rcx

.construir:

    mov eax, [rsi + rcx*4]

    mov r8, rcx
    inc r8

    cmp r8, r14
    jb .siguiente_indice

    xor r8, r8

.siguiente_indice:

    mov edx, [rsi + r8*4]

    ; Convertir indices a offsets de 64 bytes

    shl rax, 6
    shl rdx, 6

    mov [rbx + rax], rdx

    inc rcx
    cmp rcx, r14
    jb .construir

    ; Comenzar desde el primer indice

    mov r8d, [rsi]
    shl r8, 6

    ; ====================================
    ; CALENTAMIENTO
    ; ====================================

    mov ecx, ITERACIONES

.calentar:

    mov r8, [rbx + r8]

    dec ecx
    jnz .calentar

    ; ====================================
    ; CINCO MEDICIONES
    ; ====================================

    mov r15d, REPETICIONES

    mov r9, -1

.repetir:

    mov ecx, ITERACIONES

    lfence
    rdtsc

    shl rdx, 32
    or rax, rdx

    mov r12, rax

.bucle:

    mov r8, [rbx + r8]

    dec ecx
    jnz .bucle

    rdtscp
    lfence

    shl rdx, 32
    or rax, rdx

    sub rax, r12

    ; Conservar menor tiempo total

    cmp rax, r9
    jae .continuar

    mov r9, rax

.continuar:

    dec r15d
    jnz .repetir

    ; ====================================
    ; CALCULAR CICLOS POR ACCESO
    ; UTILIZAMOS EL MINIMO OBSERVADO
    ; ====================================

    mov rax, r9

    xor edx, edx
    mov ecx, ITERACIONES

    div rcx

    call imprimir_numero

    ret


; ==========================================================
; IMPRIMIR TEXTO
;
; RSI = direccion
; RDX = longitud
; ==========================================================

imprimir:

    mov eax, 1
    mov edi, 1
    syscall

    ret


; ==========================================================
; IMPRIMIR NUMERO
;
; RAX = numero entero
; ==========================================================

imprimir_numero:

    lea rdi, [numero + 32]

    xor r8d, r8d

    mov r10d, 10

.convertir:

    xor edx, edx

    div r10

    add dl, '0'

    dec rdi
    mov [rdi], dl

    inc r8d

    test rax, rax
    jnz .convertir

    mov rsi, rdi
    mov edx, r8d

    call imprimir

    lea rsi, [msg_ciclos]
    mov edx, msg_ciclos_len

    call imprimir

    ret
