#!/bin/bash

set -e

echo -n Password:
read -s password
echo

loadkeys br-abnt2

echo $password | cryptsetup open /dev/sda1 cryptbackup
echo $password | cryptsetup open /dev/sdb1 cryptroot
echo $password | cryptsetup open /dev/sdb2 cryptswap
swapon /dev/mapper/cryptswap
mkdir /mnt/backup
mount /dev/mapper/cryptbackup /mnt/backup
mount /dev/mapper/cryptroot /mnt

arch-chroot /mnt
