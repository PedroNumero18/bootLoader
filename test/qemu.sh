#!/bin/bash
# Lance QEMU avec une config de debug avancée
IMAGE="build/os-image.bin"

# Vérifie si l'image existe
if [ ! -f "$IMAGE" ]; then
    echo "Erreur: $IMAGE introuvable. Lance 'make' d'abord."
    exit 1
fi

echo "[TEST] Lancement de QEMU..."

# Explication des flags :
# -drive format=raw... : Définit le disque dur proprement
# -d int : Logue les interruptions (très utile pour debug BIOS)
# -no-reboot : QEMU se ferme au lieu de rebooter en boucle sur crash
# -D qemu.log : Écrit les logs dans un fichier
# -m 128M : Donne 128Mo de RAM
qemu-system-i386 \
    -drive file=$IMAGE,format=raw,index=0,media=disk \
    -m 128M \
    -d guest_errors,cpu_reset \
    -D qemu.log \
    -no-reboot
