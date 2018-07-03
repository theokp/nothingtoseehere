#!/bin/sh

timedatectl set-ntp true

dd if=/dev/zero of=/dev/sda bs=4096

(
printf o    # Create a new empty DOS partition table
printf n    # Add a new partition
printf p    # Primary partition
printf 1    # Partition number
printf      # First sector (Default)
printf +60G # Last sector
printf a    # Toggle a bootable flag
printf 1    # Bootable flag on partition 1
printf n    # Add a new partition
printf p    # Primary partition
printf 2    # Partition number
printf      # First sector (Default)
printf +4G  # Last sector
printf t    # Change partition type
printf 82   # Linux swap
printf n    # Add a new partition
printf p    # Primary partition
printf 3    # Partition number
printf      # First sector (Default)
printf      # Last sector
printf w    # Write changes
) | fdisk /dev/sda

mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda3

mkswap /dev/sda2
swapon /dev/sda2

mount /dev/sda1 /mnt

mkdir /mnt/home
mount /dev/sda3 /mnt/home

printf 'Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel vim intel-ucode grub dialog

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Europe/Athens /etc/localtime

hwclock --systohc

printf "el_GR.UTF-8 UTF-8" >> /etc/locale.gen
printf "el_GR ISO-8859-7" >> /etc/locale.gen
printf "en_US.UTF-8 UTF-8" >> /etc/locale.gen
printf "en_US ISO-8859-1" >> /etc/locale.gen

locale-gen

printf "LANG=en_US.UTF-8" >> /etc/locale.conf

printf "arch_narc" > /etc/hostname

printf "127.0.0.1       localhost\n::1		localhost" > /etc/hosts

grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

exit
umount -R /mnt
reboot