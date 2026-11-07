; ==========================================================
; LOWMONITOR - SISTEMA DE DIAGNOSTICO DE HARDWARE
; MODULO PRINCIPAL
;
; Arquitectura: x86-64
; Sistema operativo: Linux
; Ensamblador: NASM
; ==========================================================

default rel

section .data

titulo:
    db 10
    db "=================================================", 10
    db "       LOWMONITOR - DIAGNOSTICO DE HARDWARE", 10
    db "=================================================", 10
titulo_len equ $ - titulo

menu:
    db 10
    db "================ MENU PRINCIPAL ================", 10
 
   db " [1] Identificacion del procesador", 10
    db " [2] Monitor de puertos E/S", 10
    db " [3] Diagnostico de memoria RAM", 10
    db " [4] Analisis de rendimiento del CPU", 10
    db " [5] Gestion jerarquica de memoria", 10
    db " [6] Ejecutar todos los modulos", 10
    db " [0] Salir", 10
    db "================================================", 10
    db " Seleccione una opcion: "
menu_len equ $ - menu

msg_mod1:
    db 10, "[MODULO 1] Identificacion del CPU", 10
    db "Pendiente de implementar.", 10
msg_mod1_len equ $ - msg_mod1

msg_mod2:
    db 10, "[MODULO 2] Monitor de puertos E/S", 10
    db "Pendiente de implementar.", 10
msg_mod2_len equ $ - msg_mod2

msg_mod3:
    db 10, "[MODULO 3] Diagnostico de memoria", 10
    db "Pendiente de implementar.", 10
msg_mod3_len equ $ - msg_mod3

msg_mod4:
    db 10, "[MODULO 4] Rendimiento del CPU", 10
    db "Pendiente de implementar.", 10
msg_mod4_len equ $ - msg_mod4

msg_mod5:
    db 10, "[MODULO 5] Jerarquia de memoria", 10
    db "Pendiente de integrar.", 10
msg_mod5_len equ $ - msg_mod5

msg_todos:
    db 10, "[LOWMONITOR] Ejecutando todos los modulos...", 10
msg_todos_len equ $ - msg_todos

msg_error:
    db 10, "Opcion no valida. Intente nuevamente.", 10
msg_error_len equ $ - msg_error

msg_salida:
    db 10, "Gracias por utilizar LowMonitor.", 10
msg_salida_len equ $ - msg_salida

section .bss

opcion resb 8

section .text

global _start
extern modulo1_main
extern modulo2_main
extern modulo3_main
_start:

    lea rsi, [titulo]
    mov edx, titulo_len
    call imprimir

.menu_principal:

    lea rsi, [menu]
    mov edx, menu_len
    call imprimir

    ; Leer opcion del usuario

    mov eax, 0
    mov edi, 0
    lea rsi, [opcion]
    mov edx, 8
    syscall

    ; Si no se pudo leer, finalizar

    cmp rax, 0
    jle .salir

    mov al, [opcion]

    cmp al, '1'
    je .modulo1

    cmp al, '2'
    je .modulo2

    cmp al, '3'
    je .modulo3

    cmp al, '4'
    je .modulo4

    cmp al, '5'
    je .modulo5

    cmp al, '6'
    je .todos

    cmp al, '0'
    je .salir

    lea rsi, [msg_error]
    mov edx, msg_error_len
    call imprimir

    jmp .menu_principal

.modulo1:

    call modulo1_main

    jmp .menu_principal

.modulo2:

    call modulo2_main

    jmp .menu_principal


.modulo3:

    call modulo3_main

    jmp .menu_principal

.modulo4:

    lea rsi, [msg_mod4]
    mov edx, msg_mod4_len
    call imprimir

    jmp .menu_principal

.modulo5:

    lea rsi, [msg_mod5]
    mov edx, msg_mod5_len
    call imprimir

    jmp .menu_principal

.todos:

    lea rsi, [msg_todos]
    mov edx, msg_todos_len
    call imprimir

    lea rsi, [msg_mod1]
    mov edx, msg_mod1_len
    call imprimir

    lea rsi, [msg_mod2]
    mov edx, msg_mod2_len
    call imprimir

    lea rsi, [msg_mod3]
    mov edx, msg_mod3_len
    call imprimir

    lea rsi, [msg_mod4]
    mov edx, msg_mod4_len
    call imprimir

    lea rsi, [msg_mod5]
    mov edx, msg_mod5_len
    call imprimir

    jmp .menu_principal

.salir:

    lea rsi, [msg_salida]
    mov edx, msg_salida_len
    call imprimir

    mov eax, 60
    xor edi, edi
    syscall


; ==========================================================
; SUBRUTINA PARA IMPRIMIR TEXTO
;
; RSI = direccion
; RDX = longitud
; ==========================================================

imprimir:

    mov eax, 1
    mov edi, 1
    syscall
    ret
