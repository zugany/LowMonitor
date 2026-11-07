; =====================================================
; LOWMONITOR - PRUEBA DE PERMISOS DE PUERTOS E/S
; Linux x86-64 / NASM
; No ejecuta instrucciones IN ni OUT
; =====================================================

default rel

section .data

msg_inicio:
    db "LOWMONITOR - Prueba de permisos E/S", 10
msg_inicio_len equ $ - msg_inicio

msg_ok:
    db "Resultado: permiso concedido por Linux.", 10
msg_ok_len equ $ - msg_ok

msg_denegado:
    db "Resultado: permiso denegado (EPERM).", 10
msg_denegado_len equ $ - msg_denegado

msg_no_disponible:
    db "Resultado: llamada no implementada (ENOSYS).", 10
msg_no_disponible_len equ $ - msg_no_disponible

msg_otro:
    db "Resultado: otro error del sistema.", 10
msg_otro_len equ $ - msg_otro

section .text

global _start

_start:

    ; Mostrar encabezado
    lea rsi, [msg_inicio]
    mov edx, msg_inicio_len
    call imprimir

    ; ioperm(0x3F8, 1, 1)
    ; Solicitar permiso para un puerto
    mov eax, 173
    mov edi, 0x3F8
    mov esi, 1
    mov edx, 1
    syscall

    ; Comprobar resultado
    test rax, rax
    jz .concedido

    cmp rax, -1
    je .denegado

    cmp rax, -38
    je .no_disponible

    jmp .otro_error

.concedido:

    ; Revocar el permiso antes de salir
    mov eax, 173
    mov edi, 0x3F8
    mov esi, 1
    xor edx, edx
    syscall

    lea rsi, [msg_ok]
    mov edx, msg_ok_len
    call imprimir

    jmp .salir

.denegado:

    lea rsi, [msg_denegado]
    mov edx, msg_denegado_len
    call imprimir

    jmp .salir

.no_disponible:

    lea rsi, [msg_no_disponible]
    mov edx, msg_no_disponible_len
    call imprimir

    jmp .salir

.otro_error:

    lea rsi, [msg_otro]
    mov edx, msg_otro_len
    call imprimir

.salir:

    mov eax, 60
    xor edi, edi
    syscall

imprimir:

    mov eax, 1
    mov edi, 1
    syscall
    ret
