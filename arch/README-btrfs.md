# Arch Linux Installation Guide (btrfs)

This guide is a **step by step and end to end guide** that will set up an Arch Linux operating system with:

- UEFI using GRUB
- BTRFS file system
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

# List disks (substitute /dev/XXXX below for your disks)
fdisk -l

# Use the menus within cfdisk to create the following partitions:
# 500MB, Type=EFI
# (Remaining size of drive, automatically entered by cfdisk), Type=Linux Filesystem
cfdisk /dev/nvme0n1

# Format the partitions
mkfs.fat -F 32 -n EFI /dev/nvme0n1p1
mkfs.btrfs -L ROOT /dev/nvme0n1p2

# Mount current root and create subvolumes
mount /dev/nvme0n1p2 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@var
umount /mnt

# Mount root
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@ /dev/nvme0n1p2 /mnt

# Make directories to mount subvolumes in
mkdir /mnt/{boot,home,opt,tmp,var}

# Mount other subvolumes
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@opt /dev/nvme0n1p2 /mnt/opt
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@tmp /dev/nvme0n1p2 /mnt/tmp
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@var /dev/nvme0n1p2 /mnt/var

# Mount boot
mount /dev/nvme0n1p1 /mnt/boot

pacstrap /mnt base

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

# Please add the appropriate ucode below:
# - AMD CPU: amd-ucode
# - Intel CPU: intel-ucode
pacman -S grub grub-btrfs efibootmgr linux linux-firmware btrfs-progs vim

# Edit mkinitcpio
# Change: MODULES=()
# TO: MODULES=(btrfs) 
vim /etc/mkinitcpio.conf
mkinitcpio -p linux

mkdir -p /boot/EFI
mount /dev/nvme0n1p1 /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

ln -sf /usr/share/zoneinfo/Australia/NSW /etc/localtime
# Uncomment line 177 in /etc/locale.gen
# If you are NOT wanting en_US.UTF-8, please manually uncomment the appropriate line
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "arch" > /etc/hostname
echo "127.0.0.1 localhost 
::1 localhost
127.0.1.1 arch.localdomain arch" > /etc/hosts

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
# Substitute <USER> for your username, e.g. billiesmith
useradd -m -g users -G wheel <USER>
# Substitute <FULLNAME> for your full name, e.g. Billie Smith
chfn --full-name "<FULLNAME>" <USER>
passwd <USER>

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
