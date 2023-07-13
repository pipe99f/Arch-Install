#!/bin/bash

ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
hwclock --systohc
sed -i 's/#en_IN UTF-8/en_IN UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_IN.UTF-8" >>/etc/locale.conf
echo "arch" >>/etc/hostname
echo "127.0.0.1 localhost" >>/etc/hosts
echo "::1       localhost" >>/etc/hosts
echo "127.0.1.1 arch.localdomain arch" >>/etc/hosts
passwd

#important packages NO ESTÁ SIRVIENDO
pacman -S grub networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools linux-headers reflector avahi xdg-user-dirs xdg-utils os-prober openssh gvfs pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber efibootmgr ntp

#grub config
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

sed -i 's/#GRUB_SAVEDEFAULT=true/GRUB_SAVEDEFAULT=true/' /etc/default/grub
sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/' /etc/default/grub
sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub

#systemctl enables
systemctl enable NetworkManager
systemctl enable sshd.service
systemctl enable reflector.timer
systemctl enable avahi-daemon
systemctl enable ntpd.service

#user setup

while true; do
	read -p "Enter your username: " username
	read -p "Please re-enter your username: " username_confirm

	if [ "$username" == "$username_confirm" ]; then
		echo "Username confirmed: $username"
		break
	else
		echo "Username verification failed. Please try again."
	fi
done

useradd -m "$username"
passwd "$username"
usermod -aG wheel "$username"
echo "%wheel ALL=(ALL) ALL" >>/etc/sudoers.d/"$username"

#only for btrfs filesystem
sed -i 's/MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf

#fastest mirrors
reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

#I/O scheduler
touch /etc/udev/rules.d/60.ioschedulers.rules
tee -a /etc/udev/rules.d/60.ioschedulers.rules <<END
# HDD
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"

# SSD
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"

# NVMe SSD
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
END
