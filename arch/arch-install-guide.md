# Arch Linux Installation Guide

This guide is a **step by step and end to end guide** that will set up an Arch Linux operating system with:

- UEFI using GRUB
- Gnome
- timeshift
- audio

And will give you applications that allow you to do:

- word processing with Libreoffice
- professional audio using Bitwig and Reaper (TODO: pipewire? ardour?)
- photo management using Digikam
- music playing using TODO

It will not set you up with:

- An encrypted hard disk

## Assumptions

You have:

1. Downloaded the arch iso file
2. Copied it to a bootable USB
3. Booted your system using the arch USB
4. Are sitting at the `root@archiso` comand prompt.

When in doubt, please consult the [arch installation guide](https://wiki.archlinux.org/title/Installation_guide).

## Installation steps

I have provided minimal explanations using comments below. Please follow these steps verbatim, and if any issues come up, please consult the [arch wiki](https://wiki.archlinux.org/).

```
timedatectl set-ntp true

# List disks (substitute /dev/nvmeXXX below for your disks)
fdisk -l

# Use the menus within cfdisk to create the following partitions:
# 500MB, Type=EFI
# (Remaining size of drive, automatically entered by cfdisk), Type=Linux Filesystem
cfdisk /dev/nvme0n1

# Format the partitions
mkfs.fat -F 32 -n EFI /dev/nvme0n1p1
mkfs.ext4 -L ROOT /dev/nvme0n1p2

mount /dev/nvme0n1p2 /mnt

pacstrap /mnt base

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

pacman -S grub efibootmgr linux-lts

mkdir -p /boot/EFI
mount /dev/nvme0n1p1 /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

ln -sf /usr/share/zoneinfo/Australia/NSW /etc/localtime
# Uncomment line 177 in /etc/locale.gen
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "arch" > /etc/hostname
echo "127.0.0.1 localhost ::1 
localhost 127.0.1.1 
arch.localdomain arch" > /etc/hosts

# Use reflector to get the best mirrors for your location.
pacman -S reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bk
reflector --country "Australia" --sort rate --verbose --save /etc/pacman.d/mirrorlist

# Install Gnome and enable services
pacman -S gnome gdm networkmanager
systemctl enable gdm
systemctl enable NetworkManager

# Set the root password
passwd

# Create a user for logging in to the desktop
useradd -m -g users -G wheel brendan
passwd brendan

# Reboot into the new OS!
exit
umount -R /mnt
reboot
```

## What to do after rebooting

When your machine starts again, you will be sitting on the GDM login page.

Please click your username, enter your password, and press enter to login.

Some things to note about how Arch installs Gnome:

- Volume will be at zero, go to Settings > Sound and slide the volume fader to the right.

If you would like your system setup like me, please open a terminal, clone this repository and run the `install.sh` script.

```
git clone xxx
cd arch
sh ./install.sh
```


## TODO:

- firewalld
- printing (cups), scanning
