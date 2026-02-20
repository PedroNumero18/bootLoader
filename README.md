# BootLoader x86 - Assembleur

Un **bootloader** complet écrit en assembleur x86 16/32 bits, conçu pour initialiser une machine et charger un kernel personnalisé. Projet pédagogique explorant les bas niveaux du démarrage d'un système d'exploitation.

## Objectifs

- Comprendre le processus de boot du BIOS
- Implémenter un Stage 1 (512 octets max) pour charger le Stage 2
- Implémenter un Stage 2 qui initialise :
  - La **Global Descriptor Table (GDT)**
  - L'activation de la ligne **A20**
  - Le passage en **Mode Protégé 32 bits**
- Charger un kernel à une adresse mémoire spécifique

---

## Structure du Projet

```
bootloader/
├── Makefile                    # Build system avec cibles multiples
├── README.md                   # Ce fichier
├── doc/
│   ├── doc.md                  # Documentation technique
│   └── memory_map.txt          # Cartographie mémoire
├── src/
│   ├── common/
│   │   ├── macros.inc          # Macros assembleur réutilisables
│   │   └── print.asm           # Routines d'affichage (mode 16-bit)
│   ├── stage1/
│   │   ├── boot_entry.asm      # Point d'entrée (512 o)
│   │   └── disk_load.asm       # Chargement secteurs depuis disque
│   └── stage2/
│       ├── main.asm            # Point d'entrée Stage 2
│       ├── gdt.asm             # Global Descriptor Table
│       ├── a20.asm             # Activation ligne A20
│       └── pm.asm              # Passage en Mode Protégé
└── test/
    └── qemu.sh                 # Script de test QEMU
```

---

## ⚙️ Prérequis

### Compilation & Débogage
- **NASM** (Netwide Assembler) - Assembleur x86
- **GNU Make** - Build system
- **QEMU** (qemu-system-i386) - Émulateur x86

### Installation (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install nasm make qemu-system-x86
```

### Installation (macOS via Homebrew)

```bash
brew install nasm qemu
```

---

## Compilation & Exécution

### Compiler l'image complète

```bash
make              # Compile Stage 1 + Stage 2 → os-image.bin
make info         # Affiche les chemins de compilation
make help         # Affiche toutes les cibles disponibles
```

### Exécuter dans QEMU

```bash
make run          # Lance QEMU avec l'image
```

### Débogage interactif

```bash
make debug        # Lance QEMU en mode debug (-S -s)
# Puis connectez un débogueur (ex: gdb) sur localhost:1234
```

### Nettoyer les fichiers compilés

```bash
make clean        # Supprime build/
```

---

## Architecture

### Stage 1 - Bootloader (512 octets)

**Localisation mémoire :** `0x7C00` (adresse standard BIOS)

**Tâches :**
1. Initialiser les registres de segment (DS, ES, SS)
2. Charger le Stage 2 depuis le disque via INT 0x13 (BIOS)
3. Passer le contrôle au Stage 2

**Fichiers :**
- [src/stage1/boot_entry.asm](src/stage1/boot_entry.asm) - Point d'entrée
- [src/stage1/disk_load.asm](src/stage1/disk_load.asm) - Lecture disque

**Contraintes :**
- Taille strictement ≤ 512 octets (incluant signature 0xAA55)
- Mode réel 16-bit
- Pas d'accès aux registres 32-bit

### Stage 2 - Initialisation Mode Protégé

**Localisation mémoire :** `0x9000` (après Zone Libre)

**Tâches :**
1. Mettre en place la **GDT** (segments Code, Data, Stack)
2. Activer la **ligne A20** (accès au-delà de 1 MB)
3. Basculer en **Mode Protégé 32-bit**
4. Charger le kernel (ou boucle infinie de test)

**Fichiers :**
- [src/stage2/main.asm](src/stage2/main.asm) - Point d'entrée
- [src/stage2/gdt.asm](src/stage2/gdt.asm) - Global Descriptor Table
- [src/stage2/a20.asm](src/stage2/a20.asm) - Activation A20
- [src/stage2/pm.asm](src/stage2/pm.asm) - Mode Protégé

---

## Cartographie Mémoire

```
ADRESSE      | CONTENU
─────────────┼──────────────────────
0x000000     | BIOS IVT (512 o) - Réservé
0x000500     | Mémoire libre (~30 KiB)
0x007C00     | Stage 1 / Boot (512 o) ← Chargé par BIOS
0x007E00     | Espace libre / Stack temporaire
0x009000     | Stage 2 (jusqu'à ~48 KiB)
0x010000     | Kernel (zone réservée)
0x900000     | Stack 
```

**Règles importantes :**
- Ne jamais écrire en dessous de `0x500` (réservé BIOS)
- Le Stage 1 doit faire exactement 512 octets
- Le Stage 2 est chargé à `0x9000`

Voir [doc/memory_map.txt](doc/memory_map.txt) pour plus de détails.

---

## Débogage

### Avec GDB et QEMU

**Terminal 1 - Lancer QEMU en mode debug :**
```bash
make debug
```

**Terminal 2 - Se connecter avec GDB :**
```bash
gdb
(gdb) target remote localhost:1234
(gdb) set architecture i8086
(gdb) b *0x7c00
(gdb) c
```

### Commandes GDB utiles

```gdb
si              # Step instruction (assembleur)
ni              # Next instruction
x/10i $pc       # Disassemble 10 instructions
x/16xb $sp      # Affiche 16 bytes en hex
info registers  # État des registres
```

---

## Concepts Clés

### Mode Réel (Real Mode)

- Segment:Offset addressing → `Addr = Seg * 16 + Offset`
- Accès à ~1 MB de mémoire
- Interruptions BIOS disponibles
- Pas de protection mémoire

### Mode Protégé (Protected Mode)

- Adressage linéaire 32-bit → Accès jusqu'à 4 GB
- GDT pour définir segments (code, données, stack)
- Privilèges CPU (Ring 0-3)
- Interruptions IDT

### Interruptions BIOS utiles

- `INT 0x10` - Video display (affichage texte/graphique)
- `INT 0x13` - Mass storage (lecture/écriture disque)
- `INT 0x15` - Memory detection
- `INT 0x16` - Keyboard input

---

## Troubleshooting

### QEMU affiche : `WARNING: Image format was not specified`

**Cause :** QEMU ne reconnaît pas le format raw de l'image.

**Solution :** Vérifier que `QEMU_FLAGS` contient `-format raw` dans le Makefile.

---

## Ressources

### Documentation Officielle
- [Intel x86 ISA Reference](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-manual-combined-volumes-1-2-3-and-4.pdf) (PDF immense, mais complet)
- [NASM Manual](https://www.nasm.us/doc/)
- [QEMU Documentation](https://qemu.readthedocs.io/)
- [OSDev](https://wiki.osdev.org/Expanded_Main_Page)

---

## Notes de Développement

- **Stage 1 limité :** Les 512 octets incluent code + données + signature 0xAA55
- **Compatibilité :** Compatible BIOS uniquement (pas UEFI)
- **A20 Line :** Essential pour accéder au-delà de 1 MB en mode protégé
- **GDT placement :** Usuellement après le code Stage 2


**Dernière mise à jour :** Février 2026
