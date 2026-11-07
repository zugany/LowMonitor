# LOWMONITOR
## Sistema de Diagnóstico y Monitoreo de Hardware

**Curso:** Arquitectura de Computadoras II  
**Lenguaje:** Ensamblador NASM x86-64  
**Sistema operativo:** Ubuntu Linux sobre WSL2  
**Arquitectura:** x86-64

---

## 1. Descripción del proyecto

LowMonitor es una aplicación de consola desarrollada en lenguaje ensamblador NASM x86-64.

Su propósito es realizar pruebas de identificación del procesador, diagnóstico de memoria y análisis experimental del rendimiento del hardware.

El sistema cuenta con un menú interactivo que permite ejecutar cinco módulos individualmente o todos de manera consecutiva.

## 2. Objetivo general

Desarrollar una herramienta de diagnóstico de hardware utilizando lenguaje ensamblador, aplicando conocimientos de arquitectura de computadoras, registros, memoria, instrucciones del procesador y medición del rendimiento.

## 3. Módulos del sistema

### Módulo 1: Identificación del procesador

Consulta información del CPU mediante la instrucción CPUID.

Permite identificar:

- Fabricante del procesador.
- Modelo del procesador.
- Arquitectura x86-64.
- Extensiones SSE, SSE2, AVX y AVX2.

### Módulo 2: Monitor de puertos E/S

Presenta información sobre los siguientes puertos:

- 60h: controlador de teclado.
- 61h: control del sistema.
- 3F8h: puerto serie COM1.

El módulo realiza una comprobación de permisos de entrada/salida mediante
la llamada al sistema Linux `ioperm`, solicitando acceso al puerto `0x3F8`.

La comprobación distingue entre:

- Permiso concedido.
- Permiso denegado (`EPERM`).
- Llamada no implementada (`ENOSYS`).
- Otros errores del sistema.

En las pruebas realizadas sobre Ubuntu WSL2, `ioperm` devolvió
`ENOSYS`, por lo que no fue posible obtener permisos mediante
este mecanismo.

No se ejecutan instrucciones físicas `IN` ni `OUT`.
Por lo tanto, el requisito de acceso físico a puertos no está
implementado completamente.

### Módulo 3: Diagnóstico de memoria RAM

Realiza pruebas de escritura y lectura sobre un búfer de 4096 bytes.

Utiliza los siguientes patrones:

- 0xAA.
- 0x55.
- Patrón incremental.

El programa contabiliza bytes y bits incorrectos.

Las pruebas se realizan sobre memoria asignada al proceso, no sobre toda la RAM física.

### Módulo 4: Análisis de rendimiento del CPU

Ejecuta una carga de trabajo de 10,000,000 de iteraciones.

Utiliza contadores de rendimiento del sistema para obtener:

- Ciclos del procesador.
- Instrucciones retiradas.
- IPC: instrucciones por ciclo.
- CPI: ciclos por instrucción.

Los resultados corresponden a la carga de trabajo ejecutada y pueden variar entre mediciones.

### Módulo 5: Jerarquía de memoria

Realiza pruebas experimentales de acceso utilizando diferentes tamaños de conjuntos de datos.

Incluye:

- Operaciones con registros.
- Conjunto de 16 KiB.
- Conjunto de 256 KiB.
- Conjunto de 8 MiB.
- Conjunto de 64 MiB.

Utiliza las instrucciones `RDTSC` y `RDTSCP` para medir ciclos
del procesador durante las pruebas de acceso a memoria.

El procedimiento realiza cinco repeticiones por prueba y conserva
el menor tiempo total observado. Posteriormente divide ese valor
entre la cantidad de accesos realizados para obtener una estimación
de ciclos mínimos observados por acceso.

Por lo tanto, el resultado mostrado no representa el promedio
de las cinco repeticiones.

Los resultados permiten observar diferencias en los tiempos de
acceso a conjuntos de distintos tamaños.

Los tamaños de prueba no garantizan que cada medición corresponda exclusivamente a un nivel específico de caché.

## 4. Tecnologías utilizadas

- NASM.
- Ensamblador x86-64.
- Linux.
- Ubuntu sobre WSL2.
- GNU Make.
- GNU ld.
- Instrucciones CPUID y RDTSC/RDTSCP.
- Contadores de rendimiento de Linux.

## 5. Requisitos

Se necesita un sistema Linux x86-64 con:

- NASM.
- GNU Make.
- Binutils.
- Procesador compatible con x86-64.

En Ubuntu se pueden instalar las herramientas mediante:

```bash
sudo apt update
sudo apt install nasm make binutils -y
```

## 6. Compilación

Desde la carpeta principal del proyecto:

```bash
make
```

Para reconstruir completamente:

```bash
make rebuild
```

## 7. Ejecución

Ejecutar mediante Make:

```bash
make run
```

También se puede iniciar directamente:

```bash
./LowMonitor
```

## 8. Menú principal

```text
[1] Identificacion del procesador
[2] Monitor de puertos E/S
[3] Diagnostico de memoria RAM
[4] Analisis de rendimiento del CPU
[5] Gestion jerarquica de memoria
[6] Ejecutar todos los modulos
[0] Salir
```

## 9. Limpieza del proyecto

Para eliminar los archivos objeto y el ejecutable:

```bash
make clean
```

## 10. Limitaciones

El proyecto fue desarrollado y probado en Ubuntu sobre WSL2.

El proyecto fue probado con el kernel
`6.6.87.2-microsoft-standard-WSL2`.

Durante la verificación del entorno se observó:

- La interfaz `/dev/port` no está disponible.
- La llamada al sistema `ioperm` devolvió `ENOSYS`.
- No se realizaron operaciones físicas mediante `IN` u `OUT`.

Estos resultados documentan las restricciones observadas en
el entorno de pruebas. No demuestran que todos los mecanismos
de acceso a puertos sean imposibles en cualquier instalación Linux.

El Módulo 2 comprueba la disponibilidad de permisos, pero no
cumple completamente el requisito de ejecutar instrucciones
físicas `IN` y `OUT`.

Las pruebas de RAM se limitan a memoria asignada al proceso.

Las mediciones de rendimiento y jerarquía de memoria son
experimentales. Sus resultados pueden variar según el procesador,
la virtualización, el sistema operativo y la carga del equipo.

## 11. Conclusión

LowMonitor integra cinco módulos de diagnóstico y análisis de hardware en una aplicación de consola desarrollada con ensamblador NASM x86-64.

El proyecto permite aplicar conceptos de arquitectura de computadoras mediante instrucciones del procesador, manipulación de memoria, medición de rendimiento y automatización de compilación.
