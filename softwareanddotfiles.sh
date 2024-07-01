#!/bin/bash

# Check for Oh My Zsh installation
if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
	echo "Zsh is not the default shell"
	echo "Run chsh -s /usr/bin/zsh"
	exit 1
fi

echo "Is this a laptop?"
select yn in "Yes" "No"; do
	case $yn in
	Yes)
		sudo pacman -S acpi acpi_call tlp bluez bluez-utils brightnessctl wireless_tools
		systemctl enable bluetooth.service
		systemctl enable tlp
		break
		;;
	No) break ;;
	esac
done

#Hook that deletes pacman cache
# mkdir /etc/pacman.d/hooks && touch /etc/pacman.d/clean_pacman_cache.hook
# tee -a /etc/pacman.d/hooks/clean_pacman_cache.hook << END
# [Trigger]
# Operation = Upgrade
# Operation = Install
# Operation = Remove
# Type = Package
# Target = *
# [Action]
# Description = Cleaning pacman cache...
# When = PostTransaction
# Exec = /usr/bin/paccache -r
# END

# Some empty folders and files that I prefer to create now
touch "$HOME"/.priv
mkdir "$HOME"/Downloads/firefox

#enabling multilib
echo '[multilib]' | sudo tee -a /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' | sudo tee -a /etc/pacman.conf
sudo pacman -Sy

#enable parallel downloads
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

#install basic packages
sudo pacman --needed -S - <"$HOME"/Arch-Install/basicpacman.txt

#make pkgfile work
pkgfile -u

#create basic directories
xdg-user-dirs-update

#YAY installation. NINGUN PAQUETE AUR QUEDÓ INSTALADO CORRECTAMENTE
git clone https://aur.archlinux.org/yay-bin.git "$HOME"/yay-bin
cd "$HOME"/yay-bin
makepkg -si

# yay -S $(tr -s '\n' ' ' <"$HOME"/Arch-Install/aurpackages.txt)
# yay -S $(cat ~/Arch-Install/aurpackages.txt)

#tmux plugin manager
git clone https://github.com/tmux-plugins/tpm "$HOME"/.tmux/plugins/tpm

#custom .desktop
mkdir "$HOME"/.local/share/applications
touch "$HOME"/.local/share/applications/steamgamemode.desktop
tee -a "$HOME"/.local/share/applications/steamgamemode.desktop <<END
[Desktop Entry]
Name=Steam gamemode
Comment= Gamemode
Exec=gamemoderun steam-runtime
Icon=steam
Terminal=false
Type=Application
Categories=Game;
END

#default applications
# handlr set inode/directory thunar.desktop
# handlr set application/pdf org.pwmt.zathura.desktop

#Stow
git clone https://github.com/pipe99f/dotfiles "$HOME"/dotfiles
cd "$HOME"/dotfiles
mkdir "$HOME"/.config/joplin && rm "$HOME"/.zshrc "$HOME"/.bashrc "$HOME"/.bash_profile "$HOME"/.config/atuin/config.toml "$HOME"/.config/mimeapps.list
stow *

#enable services
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service
systemctl enable paccache.timer
systemctl enable ufw.service
systemctl enable archlinux-keyring-wkd-sync.timer
systemctl enable cups.service
systemctl enable cronie.service
systemctl enable pkgfile-update.timer
#si se usa ssd
systemctl enable fstrim.timer
systemctl enable grub-btrfsd
