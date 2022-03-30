#!/bin/bash

ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
hwclock --systohc
sed -i '168s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_IN.UTF-8" >> /etc/locale.conf
echo "KEYMAP=de_CH-latin1" >> /etc/vconsole.conf
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts
passwd

#important packages
pacman -S --noconfirm grub networkmanager network-manager-applet dialog wpa_supplicant mtools dosftools linux-headers reflector avahi xdg-user-dirs xdg-utils os-prober cups openssh gvfs pipewire pipewire-alsa pipewire-pulse


#grub config
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
update-grub

#systemctl enables 
systemctl enable NetworkManager
systemctl enable cups.service
systemctl enable fstrim.timer
systemctl enable sshd
systemctl enable pipewire
systemctl enable pipewire-pulse

#user setup
useradd -m pipe99g
passwd pipe99g
usermod -aG wheel pipe99g
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers.d/pipe99g


#only for btrfs filesystem
sed -i 's/MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf


#laptop packages (bluetooth, acpi, wifi, etc.)
pacman -S acpi acpi_call tlp bluez 

systemctl enable bluetooth
systemctl enable tlp


sudo pacman -S $(cat pacmanpackages.txt)


#YAY installation
yay -S $(cat aurpackages.txt)

#pipewire setup
systemctl --user daemon-reload
#systemctl --user --now disable pulseaudio.service pulseaudio.socket
systemctl --user --now enable pipewire pipewire-pulse


