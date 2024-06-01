#!/bin/bash

# Check for Oh My Zsh installation
if [ -f ~/.oh-my-zsh/oh-my-zsh.sh ]; then
	echo "Oh My Zsh is already installed."
else
	# Oh My Zsh is not installed
	echo "Oh My Zsh is not installed."
	echo 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

touch "$HOME"/.priv

#enabling multilib
echo '[multilib]' | sudo tee -a /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' | sudo tee -a /etc/pacman.conf
sudo pacman -Sy

#enable parallel downloads
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

#environment variables for qt6ct (not recommended this way)
# echo 'QT_QPA_PLATFORM=wayland' | sudo tee -a /etc/environment.d/qt6.conf
# echo 'QT_QPA_PLATFORMTHEME=qt6ct' | sudo tee -a /etc/environment.d/qt6.conf

#install basic packages
sudo pacman --needed -S - <"$HOME"/Arch-Install/basicpacman.txt

#create basic directories
xdg-user-dirs-update

#YAY installation. NINGUN PAQUETE AUR QUEDÓ INSTALADO CORRECTAMENTE
git clone https://aur.archlinux.org/yay-bin.git "$HOME"/yay-bin
cd "$HOME"/yay-bin
makepkg -si

# yay -S $(tr -s '\n' ' ' <"$HOME"/Arch-Install/aurpackages.txt)
# yay -S $(cat ~/Arch-Install/aurpackages.txt)

#oh my zsh, do not execute with root
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#oh my zsh plugins
git clone https://github.com/Aloxaf/fzf-tab "$HOME"/.oh-my-zsh/custom/plugins/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME"/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

#tmux plugin manager
git clone https://github.com/tmux-plugins/tpm "$HOME"/.tmux/plugins/tpm

#ranger plugins
#ranger icons
git clone https://github.com/alexanderjeurissen/ranger_devicons "$HOME"/.config/ranger/plugins/ranger_devicons

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
handlr set inode/directory thunar.desktop

#El siguiente comando es redundante porque ohmyzsh pregunta si quiero hacer a zsh el shell predeterminado
#chsh -s $(which zsh)

#Para agregar LTS al GRUB (no sé si así funciona)
# sudo grub-mkconfig -o /boot/grub/grub.cfg
# sudo grub-install --efi-directory=/boot

#Stow
git clone https://github.com/pipe99f/dotfiles "$HOME"/dotfiles
cd "$HOME"/dotfiles
mkdir "$HOME"/.config/joplin && rm "$HOME"/.zshrc "$HOME"/.bashrc "$HOME"/.bash_profile "$HOME"/.config/atuin/config.toml
stow *

#tmux sessions
# chmod u+x "$HOME"/dotfiles/scripts/scripts/t
# sudo ln -s "$HOME"/scripts/t /usr/bin/t

#enable services
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service
systemctl enable paccache.timer
systemctl enable ufw.service
systemctl enable archlinux-keyring-wkd-sync.timer
systemctl enable cups.service
systemctl enable cronie.service
#si se usa ssd
systemctl enable fstrim.timer
systemctl enable grub-btrfsd
