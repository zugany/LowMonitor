; ==========================================================
; LOWMONITOR - MODULO 2
; MONITOR DE PUERTOS DE ENTRADA Y SALIDA
; Arquitectura: x86-64 / Linux
;
; Verifica disponibilidad de permisos mediante ioperm.
; No ejecuta instrucciones IN ni OUT.
; ==========================================================

default rel

section .data

titulo:
    db 10, "========================================", 10
    db " MODULO 2 - MONITOR DE PUERTOS E/S", 10
    db "========================================", 10
titulo_len equ $ - titulo

puerto60:
    db 10, "Puerto 60h - Controlador de teclado", 10
puerto60_len equ $ - puerto60

puerto61:
    db "Puerto 61h - Control del sistema", 10
puerto61_len equ $ - puerto61

puerto3f8:
    db "Puerto 3F8h - Puerto serie COM1", 10
puerto3f8_len equ $ - puerto3f8

msg_verificacion:
    db 10, "Verificacion de permisos de E/S:", 10
msg_verificacion_len equ $ - msg_verificacion

msg_ok:
    db "Resultado: Linux concedio el permiso solicitado.", 10
msg_ok_len equ $ - msg_ok

msg_denegado:
    db "Resultado: permiso denegado (EPERM).", 10
msg_denegado_len equ $ - msg_denegado

msg_enosys:
    db "Resultado: ioperm no disponible (ENOSYS).", 10
msg_enosys_len equ $ - msg_enosys

msg_error:
    db "Resultado: otro error al solicitar permisos.", 10
msg_error_len equ $ - msg_error

msg_revocacion:
    db "Advertencia: no se pudo revocar el permiso.", 10
msg_revocacion_len equ $ - msg_revocacion

msg_fin:
    db 10, "No se realizaron operaciones fisicas IN/OUT.", 10
    db "Diagnostico finalizado.", 10, 10
msg_fin_len equ $ - msg_fin

section .text

global modulo2_main

modulo2_main:

    lea rsi, [titulo]
    mov edx, titulo_len
    call imprimir_m2

    lea rsi, [puerto60]
    mov edx, puerto60_len
    call imprimir_m2

    lea rsi, [puerto61]
    mov edx, puerto61_len
    call imprimir_m2

    lea rsi, [puerto3f8]
    mov edx, puerto3f8_len
    call imprimir_m2

    lea rsi, [msg_verificacion]
    mov edx, msg_verificacion_len
    call imprimir_m2

    ; Solicitar permiso para un solo puerto: 0x3F8
    ; ioperm(from=0x3F8, num=1, turn_on=1)

    mov eax, 173
    mov edi, 0x3F8
    mov esi, 1
    mov edx, 1
    syscall

    test rax, rax
    jz .permiso_concedido

    cmp rax, -1
    je .permiso_denegado

    cmp rax, -38
    je .no_implementado

    jmp .otro_error

.permiso_concedido:

    ; Revocar inmediatamente el permiso solicitado
    mov eax, 173
    mov edi, 0x3F8
    mov esi, 1
    xor edx, edx
    syscall

    test rax, rax
    jnz .error_revocacion

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call imprimir_m2
    jmp .finalizar

.error_revocacion:

    lea rsi, [msg_revocacion]
    mov edx, msg_revocacion_len
    call imprimir_m2
    jmp .finalizar

.permiso_denegado:

    lea rsi, [msg_denegado]
    mov edx, msg_denegado_len
    call imprimir_m2
    jmp .finalizar

.no_implementado:

    lea rsi, [msg_enosys]
    mov edx, msg_enosys_len
    call imprimir_m2
    jmp .finalizar

.otro_error:

    lea rsi, [msg_error]
    mov edx, msg_error_len
    call imprimir_m2

.finalizar:

    lea rsi, [msg_fin]
    mov edx, msg_fin_len
    call imprimir_m2

    ret

imprimir_m2:

    mov eax, 1
    mov edi, 1
    syscall
    ret
