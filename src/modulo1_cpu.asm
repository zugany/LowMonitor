; ==========================================================
; LOWMONITOR - MODULO 1
; IDENTIFICACION DEL PROCESADOR
; Arquitectura: x86-64 / Linux
; ==========================================================

default rel

section .data

titulo:
    db 10, "========================================", 10
    db " MODULO 1 - IDENTIFICACION DEL CPU", 10
    db "========================================", 10
titulo_len equ $ - titulo

msg_fabricante db "Fabricante: "
len_fabricante equ $ - msg_fabricante

msg_modelo db "Procesador: "
len_modelo equ $ - msg_modelo

msg_familia db "Familia del CPU: "
len_familia equ $ - msg_familia

msg_modelo_num db "Modelo numerico: "
len_modelo_num equ $ - msg_modelo_num

msg_stepping db "Stepping: "
len_stepping equ $ - msg_stepping

msg_arq db "Arquitectura: x86-64", 10
len_arq equ $ - msg_arq

msg_ext db "Extensiones disponibles: "
len_ext equ $ - msg_ext

str_sse db "SSE "
len_sse equ $ - str_sse

str_sse2 db "SSE2 "
len_sse2 equ $ - str_sse2

str_avx db "AVX "
len_avx equ $ - str_avx

str_avx2 db "AVX2 "
len_avx2 equ $ - str_avx2

str_avx512 db "AVX-512F "
len_avx512 equ $ - str_avx512

msg_no db "No detectadas"
len_no equ $ - msg_no

salto db 10
len_salto equ $ - salto

section .bss

fabricante resb 12
modelo resb 48

section .text

global modulo1_main

modulo1_main:

    push rbx
    push r12
    push r13
    push r14
    push r15

    lea rsi, [titulo]
    mov edx, titulo_len
    call imprimir_m1

    ; ----------------------------------
    ; FABRICANTE
    ; ----------------------------------

    xor eax, eax
    cpuid

    mov [fabricante], ebx
    mov [fabricante + 4], edx
    mov [fabricante + 8], ecx

    mov r14d, eax

    lea rsi, [msg_fabricante]
    mov edx, len_fabricante
    call imprimir_m1

    lea rsi, [fabricante]
    mov edx, 12
    call imprimir_m1

    call nueva_linea_m1

    ; ----------------------------------
    ; MODELO DEL PROCESADOR
    ; ----------------------------------

    mov eax, 0x80000000
    cpuid

    cmp eax, 0x80000004
    jb .sin_modelo

    mov eax, 0x80000002
    cpuid

    mov [modelo], eax
    mov [modelo + 4], ebx
    mov [modelo + 8], ecx
    mov [modelo + 12], edx

    mov eax, 0x80000003
    cpuid

    mov [modelo + 16], eax
    mov [modelo + 20], ebx
    mov [modelo + 24], ecx
    mov [modelo + 28], edx

    mov eax, 0x80000004
    cpuid

    mov [modelo + 32], eax
    mov [modelo + 36], ebx
    mov [modelo + 40], ecx
    mov [modelo + 44], edx

    lea rsi, [msg_modelo]
    mov edx, len_modelo
    call imprimir_m1

    lea rsi, [modelo]
    mov edx, 48
    call imprimir_m1

    call nueva_linea_m1

.sin_modelo:

    lea rsi, [msg_arq]
    mov edx, len_arq
    call imprimir_m1

    ; ----------------------------------
    ; FAMILIA, MODELO NUMERICO Y STEPPING
    ; CPUID hoja 1: EAX
    ; ----------------------------------

    cmp r14d, 1
    jb .fin_datos_cpu

    mov eax, 1
    cpuid

    mov r10d, eax

    ; Stepping: bits 3:0
    mov r12d, eax
    and r12d, 0xF

    ; Familia base: bits 11:8
    mov r13d, eax
    shr r13d, 8
    and r13d, 0xF

    ; Modelo base: bits 7:4
    mov r15d, eax
    shr r15d, 4
    and r15d, 0xF

    ; Familia extendida: bits 27:20
    mov r8d, eax
    shr r8d, 20
    and r8d, 0xFF

    ; Modelo extendido: bits 19:16
    mov r9d, eax
    shr r9d, 16
    and r9d, 0xF

    ; Familia efectiva
    cmp r13d, 0xF
    jne .familia_lista
    add r13d, r8d

.familia_lista:

    ; Modelo efectivo: se extiende si familia base es 6 o F
    mov eax, r10d
    shr eax, 8
    and eax, 0xF

    cmp eax, 6
    je .modelo_extendido
    cmp eax, 0xF
    jne .modelo_listo

.modelo_extendido:

    shl r9d, 4
    add r15d, r9d

.modelo_listo:

    lea rsi, [msg_familia]
    mov edx, len_familia
    call imprimir_m1

    mov eax, r13d
    call imprimir_decimal_m1
    call nueva_linea_m1

    lea rsi, [msg_modelo_num]
    mov edx, len_modelo_num
    call imprimir_m1

    mov eax, r15d
    call imprimir_decimal_m1
    call nueva_linea_m1

    lea rsi, [msg_stepping]
    mov edx, len_stepping
    call imprimir_m1

    mov eax, r12d
    call imprimir_decimal_m1
    call nueva_linea_m1

.fin_datos_cpu:

    call nueva_linea_m1

    ; ----------------------------------
    ; DETECTAR EXTENSIONES
    ; ----------------------------------

    lea rsi, [msg_ext]
    mov edx, len_ext
    call imprimir_m1

    xor r12d, r12d
    xor r13d, r13d
    xor r15d, r15d

    cmp r14d, 1
    jb .fin_extensiones

    mov eax, 1
    cpuid

    mov r12d, edx
    mov r13d, ecx

    test r12d, 1 << 25
    jz .sse2

    lea rsi, [str_sse]
    mov edx, len_sse
    call imprimir_m1
    mov r15d, 1

.sse2:

    test r12d, 1 << 26
    jz .avx

    lea rsi, [str_sse2]
    mov edx, len_sse2
    call imprimir_m1
    mov r15d, 1

.avx:

    ; Verificar XSAVE, OSXSAVE y AVX
    mov eax, r13d
    and eax, (1 << 26) | (1 << 27) | (1 << 28)
    cmp eax, (1 << 26) | (1 << 27) | (1 << 28)
    jne .fin_extensiones

    xor ecx, ecx
    xgetbv

    mov r12d, eax

    and eax, 6
    cmp eax, 6
    jne .fin_extensiones

    lea rsi, [str_avx]
    mov edx, len_avx
    call imprimir_m1
    mov r15d, 1

    ; Consultar CPUID hoja 7

    cmp r14d, 7
    jb .fin_extensiones

    mov eax, 7
    xor ecx, ecx
    cpuid

    mov r13d, ebx

    test r13d, 1 << 5
    jz .avx512

    lea rsi, [str_avx2]
    mov edx, len_avx2
    call imprimir_m1
    mov r15d, 1

.avx512:

    ; XCR0 debe habilitar registros ZMM
    mov eax, r12d
    and eax, 0xE6
    cmp eax, 0xE6
    jne .fin_extensiones

    test r13d, 1 << 16
    jz .fin_extensiones

    lea rsi, [str_avx512]
    mov edx, len_avx512
    call imprimir_m1
    mov r15d, 1

.fin_extensiones:

    test r15d, r15d
    jnz .terminar

    lea rsi, [msg_no]
    mov edx, len_no
    call imprimir_m1

.terminar:

    call nueva_linea_m1
    call nueva_linea_m1

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx

    ret


; ----------------------------------
; FUNCIONES AUXILIARES
; ----------------------------------

imprimir_m1:

    mov eax, 1
    mov edi, 1
    syscall
    ret

nueva_linea_m1:

    lea rsi, [salto]
    mov edx, len_salto
    call imprimir_m1
    ret

; ----------------------------------
; IMPRIMIR ENTERO DECIMAL SIN SIGNO
; Entrada: EAX
; ----------------------------------

imprimir_decimal_m1:
    sub rsp, 40
    lea rsi, [rsp + 39]
    mov ecx, 10

.convertir:
    xor edx, edx
    div ecx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    test eax, eax
    jnz .convertir

    lea rdx, [rsp + 39]
    sub rdx, rsi
    call imprimir_m1
    add rsp, 40
    ret
