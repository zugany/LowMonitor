; ==========================================================
; LOWMONITOR - MODULO 4
; ANALISIS DE RENDIMIENTO DEL CPU
;
; Arquitectura: Linux x86-64
; Ensamblador: NASM
;
; Medicion mediante perf_event_open:
;   - Ciclos del procesador
;   - Instrucciones retiradas
;   - IPC y CPI calculados
;
; No utiliza valores de rendimiento predefinidos.
; ==========================================================

default rel

%define SYS_READ              0
%define SYS_WRITE             1
%define SYS_CLOSE             3
%define SYS_IOCTL            16
%define SYS_PERF_EVENT_OPEN 298

%define PERF_TYPE_HARDWARE    0
%define PERF_COUNT_CYCLES     0
%define PERF_COUNT_INSTR      1

%define PERF_EVENT_IOC_ENABLE  0x2400
%define PERF_EVENT_IOC_DISABLE 0x2401
%define PERF_EVENT_IOC_RESET   0x2403

%define PERF_IOC_FLAG_GROUP    1

%define PERF_FORMAT_GROUP      8

%define ITERACIONES       10000000

section .data

titulo_m4:
    db 10
    db "================================================", 10
    db " LOWMONITOR - MODULO 4", 10
    db " ANALISIS DE RENDIMIENTO DEL CPU", 10
    db "================================================", 10
titulo_m4_len equ $ - titulo_m4

msg_carga:
    db "Carga de trabajo: 10,000,000 iteraciones", 10
msg_carga_len equ $ - msg_carga

msg_ciclos:
    db 10, "Ciclos del CPU: "
msg_ciclos_len equ $ - msg_ciclos

msg_instrucciones:
    db 10, "Instrucciones retiradas: "
msg_instrucciones_len equ $ - msg_instrucciones

msg_ipc:
    db "IPC aproximado: "
msg_ipc_len equ $ - msg_ipc

msg_cpi:
    db "CPI aproximado: "
msg_cpi_len equ $ - msg_cpi

msg_ok:
    db 10, "Estado: MEDICION COMPLETADA", 10, 10
msg_ok_len equ $ - msg_ok

msg_error:
    db 10
    db "No se pudieron utilizar los contadores.", 10
    db "Verifique los permisos y el entorno Linux.", 10, 10
msg_error_len equ $ - msg_error

msg_sin_datos:
    db 10
    db "Los contadores no devolvieron datos validos.", 10, 10
msg_sin_datos_len equ $ - msg_sin_datos

salto_m4 db 10

; perf_event_attr, 112 bytes.
; Campo flags:
; disabled = bit 0
; exclude_kernel = bit 5
; exclude_hv = bit 6

align 8
attr_ciclos:
    dd PERF_TYPE_HARDWARE
    dd 112
    dq PERF_COUNT_CYCLES
    dq 0
    dq 0
    dq PERF_FORMAT_GROUP
    dq 0x61
    times 64 db 0

align 8
attr_instrucciones:
    dd PERF_TYPE_HARDWARE
    dd 112
    dq PERF_COUNT_INSTR
    dq 0
    dq 0
    dq 0
    dq 0x60
    times 64 db 0

section .bss

fd_ciclos resq 1
fd_instrucciones resq 1

; Lectura agrupada:
; nr, ciclos, instrucciones
datos_grupo resq 3

numero_m4 resb 32

section .text

global modulo4_main

modulo4_main:

    push rbx
    push r12
    push r13
    push r14
    push r15

    mov qword [fd_ciclos], -1
    mov qword [fd_instrucciones], -1

    lea rsi, [titulo_m4]
    mov edx, titulo_m4_len
    call imprimir_m4

    lea rsi, [msg_carga]
    mov edx, msg_carga_len
    call imprimir_m4

    ; =========================================
    ; ABRIR CONTADOR DE CICLOS (LIDER)
    ; =========================================

    mov eax, SYS_PERF_EVENT_OPEN

    lea rdi, [attr_ciclos]

    xor esi, esi
    mov edx, -1
    mov r10d, -1
    xor r8d, r8d

    syscall

    test rax, rax
    js .error

    mov [fd_ciclos], rax

    ; =========================================
    ; ABRIR CONTADOR DE INSTRUCCIONES
    ; =========================================

    mov eax, SYS_PERF_EVENT_OPEN

    lea rdi, [attr_instrucciones]

    xor esi, esi
    mov edx, -1

    mov r10, [fd_ciclos]
    xor r8d, r8d

    syscall

    test rax, rax
    js .error

    mov [fd_instrucciones], rax

    ; =========================================
    ; REINICIAR GRUPO
    ; =========================================

    mov eax, SYS_IOCTL
    mov rdi, [fd_ciclos]
    mov esi, PERF_EVENT_IOC_RESET
    mov edx, PERF_IOC_FLAG_GROUP
    syscall

    test rax, rax
    js .error

    ; =========================================
    ; ACTIVAR GRUPO
    ; =========================================

    mov eax, SYS_IOCTL
    mov rdi, [fd_ciclos]
    mov esi, PERF_EVENT_IOC_ENABLE
    mov edx, PERF_IOC_FLAG_GROUP
    syscall

    test rax, rax
    js .error

    ; =========================================
    ; CARGA DE TRABAJO EN ENSAMBLADOR
    ; =========================================

    mov ecx, ITERACIONES
    xor r12d, r12d

.bucle:

    add r12, rcx
    xor r12, 0x55
    rol r12, 1

    dec ecx
    jnz .bucle

    ; =========================================
    ; DETENER GRUPO
    ; =========================================

    mov eax, SYS_IOCTL
    mov rdi, [fd_ciclos]
    mov esi, PERF_EVENT_IOC_DISABLE
    mov edx, PERF_IOC_FLAG_GROUP
    syscall

    test rax, rax
    js .error

    ; =========================================
    ; LEER AMBOS CONTADORES
    ; =========================================

    mov eax, SYS_READ
    mov rdi, [fd_ciclos]
    lea rsi, [datos_grupo]
    mov edx, 24
    syscall

    cmp rax, 24
    jne .error

    ; datos_grupo[0] = numero de eventos
    ; datos_grupo[1] = ciclos
    ; datos_grupo[2] = instrucciones

    cmp qword [datos_grupo], 2
    jne .sin_datos

    mov r13, [datos_grupo + 8]
    mov r14, [datos_grupo + 16]

    test r13, r13
    jz .sin_datos

    test r14, r14
    jz .sin_datos

    ; =========================================
    ; MOSTRAR CICLOS
    ; =========================================

    lea rsi, [msg_ciclos]
    mov edx, msg_ciclos_len
    call imprimir_m4

    mov rax, r13
    call imprimir_numero_m4
    call nueva_linea_m4

    ; =========================================
    ; MOSTRAR INSTRUCCIONES
    ; =========================================

    lea rsi, [msg_instrucciones]
    mov edx, msg_instrucciones_len
    call imprimir_m4

    mov rax, r14
    call imprimir_numero_m4
    call nueva_linea_m4

    ; =========================================
    ; CALCULAR IPC
    ;
    ; IPC = instrucciones / ciclos
    ; Se muestra con cuatro decimales.
    ; =========================================

    lea rsi, [msg_ipc]
    mov edx, msg_ipc_len
    call imprimir_m4

    mov rax, r14
    mov rbx, r13

    call imprimir_ratio_m4
    call nueva_linea_m4

    ; =========================================
    ; CALCULAR CPI
    ;
    ; CPI = ciclos / instrucciones
    ; =========================================

    lea rsi, [msg_cpi]
    mov edx, msg_cpi_len
    call imprimir_m4

    mov rax, r13
    mov rbx, r14

    call imprimir_ratio_m4
    call nueva_linea_m4

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call imprimir_m4

    jmp .finalizar

.sin_datos:

    lea rsi, [msg_sin_datos]
    mov edx, msg_sin_datos_len
    call imprimir_m4

    jmp .finalizar

.error:

    lea rsi, [msg_error]
    mov edx, msg_error_len
    call imprimir_m4

.finalizar:

    ; Cerrar descriptores abiertos

    cmp qword [fd_instrucciones], -1
    je .cerrar_ciclos

    mov eax, SYS_CLOSE
    mov rdi, [fd_instrucciones]
    syscall

.cerrar_ciclos:

    cmp qword [fd_ciclos], -1
    je .salir

    mov eax, SYS_CLOSE
    mov rdi, [fd_ciclos]
    syscall

.salir:

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx

    ret


; ==========================================================
; IMPRIMIR TEXTO
; RSI = direccion
; RDX = longitud
; ==========================================================

imprimir_m4:

    mov eax, SYS_WRITE
    mov edi, 1
    syscall
    ret


; ==========================================================
; IMPRIMIR ENTERO SIN SIGNO
; RAX = numero
; ==========================================================

imprimir_numero_m4:

    lea rdi, [numero_m4 + 32]

    mov r10d, 10
    xor r8d, r8d

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

    call imprimir_m4

    ret


; ==========================================================
; IMPRIMIR RELACION CON 4 DECIMALES
;
; Entrada:
; RAX = numerador
; RBX = denominador
;
; Ejemplo: 1.2345
; ==========================================================

imprimir_ratio_m4:

    push r12
    push r13

    xor edx, edx
    div rbx

    mov r12, rdx

    call imprimir_numero_m4

    ; Imprimir punto decimal

    sub rsp, 8
    mov byte [rsp], '.'

    lea rsi, [rsp]
    mov edx, 1
    call imprimir_m4

    add rsp, 8

    ; Calcular parte decimal

    mov rax, r12
    mov ecx, 10000
    mul rcx

    div rbx

    mov r13, rax

    ; Convertir exactamente cuatro cifras

    lea rdi, [numero_m4 + 32]

    mov ecx, 4
    mov r10d, 10

.decimales:

    mov rax, r13
    xor edx, edx
    div r10

    mov r13, rax

    add dl, '0'
    dec rdi
    mov [rdi], dl

    dec ecx
    jnz .decimales

    mov rsi, rdi
    mov edx, 4
    call imprimir_m4

    pop r13
    pop r12

    ret


nueva_linea_m4:

    lea rsi, [salto_m4]
    mov edx, 1
    call imprimir_m4

    ret
