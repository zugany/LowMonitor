# ==========================================================
# LOWMONITOR - SISTEMA DE DIAGNOSTICO DE HARDWARE
# Arquitectura de Computadoras II
# NASM / Linux x86-64
# ==========================================================

NASM = nasm
LD = ld

NASMFLAGS = -f elf64

SRC_DIR = src
BUILD_DIR = build

TARGET = LowMonitor

SOURCES = $(SRC_DIR)/main.asm \
          $(SRC_DIR)/modulo1_cpu.asm \
          $(SRC_DIR)/modulo2_puertos.asm \
          $(SRC_DIR)/modulo3_memoria.asm \
          $(SRC_DIR)/modulo4_rendimiento.asm \
          $(SRC_DIR)/modulo5_jerarquia.asm

OBJECTS = $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.o,$(SOURCES))

.PHONY: all clean run rebuild

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(OBJECTS) -o $(TARGET)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	@mkdir -p $(BUILD_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(OBJECTS) $(TARGET)

rebuild: clean all
