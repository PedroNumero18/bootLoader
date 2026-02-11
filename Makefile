ASM         = nasm
ASM_FLAGS   = -f bin
QEMU        = qemu-system-i386
QEMU_FLAGS  = -fda

SRC_DIR     = src
BUILD_DIR   = build

# Le Stage 1 (doit faire exactement 512 octets une fois compilé)
BOOT_SRC    = $(SRC_DIR)/stage1/boot_entry.asm

# Le Stage 2 (contient GDT, Switch PM, etc.)
STAGE2_SRC  = $(SRC_DIR)/stage2/main.asm

BOOT_BIN    = $(BUILD_DIR)/boot.bin
STAGE2_BIN  = $(BUILD_DIR)/stage2.bin
OS_IMAGE    = $(BUILD_DIR)/os-image.bin

.PHONY: all clean run dirs

all: dirs $(OS_IMAGE)

# 1. Création de l'image finale par Concaténation bout à bout des 2 stages
$(OS_IMAGE): $(BOOT_BIN) $(STAGE2_BIN)
	cat $^ > $@

$(BOOT_BIN): $(BOOT_SRC)
	$(ASM) $(ASM_FLAGS) -I $(SRC_DIR)/common/ $< -o $@

$(STAGE2_BIN): $(STAGE2_SRC) $(wildcard $(SRC_DIR)/stage2/*.asm)
	$(ASM) $(ASM_FLAGS) -I $(SRC_DIR)/common/ -I $(SRC_DIR)/stage2/ $< -o $@
dirs:
	@mkdir -p $(BUILD_DIR)

run: all
	$(QEMU) $(QEMU_FLAGS) $(OS_IMAGE)

debug: all
	$(QEMU) -S -s $(QEMU_FLAGS) $(OS_IMAGE)

clean:
	rm -rf $(BUILD_DIR)
