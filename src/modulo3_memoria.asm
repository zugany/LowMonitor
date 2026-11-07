; ==========================================================
; LOWMONITOR - MODULO 3
; DIAGNOSTICO DE MEMORIA
; NASM / Linux x86-64
;
; Prueba un buffer de 4096 bytes con tres patrones.
; Cuenta bytes incorrectos y bits incorrectos.
; ==========================================================

default rel

%define TAM_BUFFER 4096

section .data

titulo_m3:
    db 10, "========================================", 10
    db " MODULO 3 - DIAGNOSTICO DE MEMORIA", 10
    db "========================================", 10
titulo_m3_len equ $ - titulo_m3

msg_tamano:
    db "Memoria examinada: 4096 bytes", 10
msg_tamano_len equ $ - msg_tamano

msg_aa:
    db 10, "Patron 0xAA:", 10
msg_aa_len equ $ - msg_aa

msg_55:
    db 10, "Patron 0x55:", 10
msg_55_len equ $ - msg_55

msg_inc:
    db 10, "Patron incremental:", 10
msg_inc_len equ $ - msg_inc

msg_bytes:
    db "Bytes incorrectos: "
msg_bytes_len equ $ - msg_bytes

msg_bits:
    db "Bits incorrectos: "
msg_bits_len equ $ - msg_bits

msg_correcto:
    db "Resultado: SIN ERRORES DETECTADOS", 10
msg_correcto_len equ $ - msg_correcto

msg_error:
    db "Resultado: SE DETECTARON ERRORES", 10
msg_error_len equ $ - msg_error

msg_fin:
    db 10, "Diagnostico de memoria finalizado.", 10, 10
msg_fin_len equ $ - msg_fin

salto_m3 db 10

section .bss

align 16
buffer_m3 resb TAM_BUFFER
numero_m3 resb 32

section .text

global modulo3_main

modulo3_main:

    push rbx
    push r12
    push r13
    push r14
    push r15

    lea rsi, [titulo_m3]
    mov edx, titulo_m3_len
    call imprimir_m3

    lea rsi, [msg_tamano]
    mov edx, msg_tamano_len
    call imprimir_m3

    ; --------------------------------
    ; PRUEBA 0xAA
    ; --------------------------------

    lea rsi, [msg_aa]
    mov edx, msg_aa_len
    call imprimir_m3

    mov r12d, 0
    mov r13d, 0

    lea rdi, [buffer_m3]
    mov ecx, TAM_BUFFER
    mov al, 0xAA
    rep stosb

    mov r14d, 0xAA
    call verificar_m3

    call mostrar_resultado_m3

    ; --------------------------------
    ; PRUEBA 0x55
    ; --------------------------------

    lea rsi, [msg_55]
    mov edx, msg_55_len
    call imprimir_m3

    mov r12d, 0
    mov r13d, 0

    lea rdi, [buffer_m3]
    mov ecx, TAM_BUFFER
    mov al, 0x55
    rep stosb

    mov r14d, 0x55
    call verificar_m3

    call mostrar_resultado_m3

    ; --------------------------------
    ; PRUEBA INCREMENTAL
    ; --------------------------------

    lea rsi, [msg_inc]
    mov edx, msg_inc_len
    call imprimir_m3

    mov r12d, 0
    mov r13d, 0

    lea rdi, [buffer_m3]
    xor ecx, ecx

.escribir_incremental:

    mov [rdi + rcx], cl

    inc rcx
    cmp rcx, TAM_BUFFER
    jb .escribir_incremental

    lea rdi, [buffer_m3]
    xor rcx, rcx

.verificar_incremental:

    movzx eax, byte [rdi + rcx]

    mov edx, ecx
    and edx, 255

    xor eax, edx

    call contar_diferencias_m3

    inc rcx
    cmp rcx, TAM_BUFFER
    jb .verificar_incremental

    call mostrar_resultado_m3

    lea rsi, [msg_fin]
    mov edx, msg_fin_len
    call imprimir_m3

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx

    ret


; ==========================================================
; VERIFICAR PATRON FIJO
; R14B = patron esperado
; ==========================================================

verificar_m3:

    lea rdi, [buffer_m3]
    xor rcx, rcx

.bucle:

    movzx eax, byte [rdi + rcx]

    xor al, r14b

    call contar_diferencias_m3

    inc rcx
    cmp rcx, TAM_BUFFER
    jb .bucle

    ret


; ==========================================================
; CONTAR DIFERENCIAS
;
; EAX = XOR entre valor real y esperado
; R12 = bytes incorrectos
; R13 = bits incorrectos
; ==========================================================

contar_diferencias_m3:

    test al, al
    jz .fin

    inc r12

    movzx eax, al
    popcnt eax, eax

    add r13, rax

.fin:
    ret


; ==========================================================
; MOSTRAR RESULTADO
; ==========================================================

mostrar_resultado_m3:

    lea rsi, [msg_bytes]
    mov edx, msg_bytes_len
    call imprimir_m3

    mov rax, r12
    call imprimir_numero_m3

    call nueva_linea_m3

    lea rsi, [msg_bits]
    mov edx, msg_bits_len
    call imprimir_m3

    mov rax, r13
    call imprimir_numero_m3

    call nueva_linea_m3

    test r12, r12
    jnz .errores

    lea rsi, [msg_correcto]
    mov edx, msg_correcto_len
    call imprimir_m3

    ret

.errores:

    lea rsi, [msg_error]
    mov edx, msg_error_len
    call imprimir_m3

    ret


; ==========================================================
; IMPRIMIR NUMERO ENTERO
; Entrada: RAX
; ==========================================================

imprimir_numero_m3:

    lea rdi, [numero_m3 + 32]

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

    call imprimir_m3

    ret


; ==========================================================
; IMPRIMIR TEXTO
; ==========================================================

imprimir_m3:

    mov eax, 1
    mov edi, 1
    syscall
    ret


nueva_linea_m3:

    lea rsi, [salto_m3]
    mov edx, 1
    call imprimir_m3
    ret
