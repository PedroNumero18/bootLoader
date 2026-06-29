ASM         = nasm
ASM_FLAGS   = -f bin
QEMU        = qemu-system-i386
QEMU_FLAGS  = -hda

SRC_DIR     = src
COMMON_DIR  = $(SRC_DIR)/common
STAGE1_DIR  = $(SRC_DIR)/stage1
STAGE2_DIR  = $(SRC_DIR)/stage2

BUILD_DIR   = build
BUILD_STAGE1_DIR = $(BUILD_DIR)/stage1
BUILD_STAGE2_DIR = $(BUILD_DIR)/stage2

# SOURCES STAGE 1 - Bootloader (512 octets)
STAGE1_MAIN  = $(STAGE1_DIR)/boot_entry.asm
STAGE1_SRCS  = $(STAGE1_DIR)/disk_load.asm
STAGE1_DEPS  = $(COMMON_DIR)/macros.inc

STAGE1_BIN   = $(BUILD_STAGE1_DIR)/boot.bin


# SOURCES STAGE 2 - Mode Protégé (GDT, A20, etc.)
STAGE2_MAIN  = $(STAGE2_DIR)/main.asm
STAGE2_SRCS  = $(STAGE2_DIR)/gdt.asm \
               $(STAGE2_DIR)/a20.asm \
               $(STAGE2_DIR)/pm.asm
STAGE2_DEPS  = $(COMMON_DIR)/macros.inc $(COMMON_DIR)/print.asm

STAGE2_BIN   = $(BUILD_STAGE2_DIR)/stage2.bin

OS_IMAGE     = $(BUILD_DIR)/os-image.bin

.PHONY: all clean run debug help info dirs

all: info $(OS_IMAGE)

# Image finale: concaténation des deux stages
$(OS_IMAGE): $(STAGE1_BIN) $(STAGE2_BIN)
	@echo "  LINK    $@"
	@cat $^ > $@
	@SIZE=$$(stat -c%s $@); \
	if [ $$((SIZE % 512)) -ne 0 ]; then \
	  PADDING=$$((512 - SIZE % 512)); \
	  dd if=/dev/zero bs=1 count=$$PADDING >> $@ 2>/dev/null; \
	  echo "  ✓ Padded image to $$((SIZE + PADDING)) bytes"; \
	fi
	@echo "  ✓ Image créée: $@"

# COMPILATION STAGE 1
$(BUILD_STAGE1_DIR):
	@mkdir -p $@

$(STAGE1_BIN): $(STAGE1_MAIN) $(STAGE1_SRCS) $(STAGE1_DEPS) | $(BUILD_STAGE1_DIR)
	@echo "  ASM     $<"
	@$(ASM) $(ASM_FLAGS) -I $(COMMON_DIR) -I $(STAGE1_DIR) $(STAGE1_MAIN) -o $@
	@$(call check_size_stage1)

# COMPILATION STAGE 2
$(BUILD_STAGE2_DIR):
	@mkdir -p $@

$(STAGE2_BIN): $(STAGE2_MAIN) $(STAGE2_SRCS) $(STAGE2_DEPS) | $(BUILD_STAGE2_DIR)
	@echo "  ASM     $<"
	@$(ASM) $(ASM_FLAGS) -I $(COMMON_DIR) -I $(STAGE2_DIR) $(STAGE2_MAIN) -o $@

info:
	@echo "=========================================="
	@echo "  Bootloader Build"
	@echo "=========================================="
	@echo "  Stage 1:  $(STAGE1_BIN)"
	@echo "  Stage 2:  $(STAGE2_BIN)"
	@echo "  Output:   $(OS_IMAGE)"
	@echo "=========================================="

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Cibles principales:"
	@echo "  all       - Compiler l'image complète (défaut)"
	@echo "  run       - Exécuter l'image dans QEMU"
	@echo "  debug     - Lancer QEMU en mode debug (-S -s)"
	@echo "  clean     - Nettoyer les fichiers compilés"
	@echo ""
	@echo "Cibles utilitaires:"
	@echo "  info      - Afficher les chemins de compilation"
	@echo "  help      - Afficher cette aide"
	@echo ""
	@echo "Variables personnalisables:"
	@echo "  ASM       - Assembleur (défaut: nasm)"
	@echo "  QEMU      - Émulateur (défaut: qemu-system-i386)"

run: all
	@echo "  QEMU    $(OS_IMAGE)"
	@$(QEMU) $(QEMU_FLAGS) $(OS_IMAGE)

debug: all
	@echo "  QEMU    $(OS_IMAGE) [DEBUG MODE]"
	@$(QEMU) -S -s $(QEMU_FLAGS) $(OS_IMAGE)

clean:
	@echo "  CLEAN   $(BUILD_DIR)"
	@rm -rf $(BUILD_DIR)
	@echo "  ✓ Nettoyage terminé"

define check_size_stage1
	@SIZE=$$(stat -c%s $(STAGE1_BIN)); \
	if [ $$SIZE -gt 512 ]; then \
		echo "  ✗ ERREUR: Stage 1 fait $$SIZE octets (max 512)"; \
		exit 1; \
	fi; \
	echo "  ✓ Stage 1: $$SIZE/512 octets"
endef
