#laptop packages (bluetooth, acpi, wifi, etc.)
#falta hacer un checkbox que especifique que estos packages son para laptop
cd
sudo pacman -S acpi acpi_call tlp bluez bluez-utils brightnessctl

systemctl enable bluetooth.service
systemctl enable tlp

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

#enabling multilib
sudo echo '[multilib]' >>/etc/pacman.conf
sudo echo 'Include = /etc/pacman.d/mirrorlist' >>/etc/pacman.conf
sudo pacman -Sy

#enable parallel downloads
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

#install basic packages
sudo pacman -S "$(cat ~/Arch-install/pacmanpackages.txt)"

#create basic directories
xdg-user-dirs-update

#YAY installation. NINGUN PAQUETE AUR QUEDÓ INSTALADO CORRECTAMENTE
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

yay -S "$(cat ~/Arch-install/aurpackages.txt)"

#pipewire setup
#systemctl --user daemon-reload
#systemctl --user --now disable pulseaudio.service pulseaudio.socket

#oh my zsh
cd
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#oh my zsh plugins
cd ~/.oh-my-zsh/plugins/
git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting

#tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

#icons in terminal
cd ~/Downloads/
git clone https://github.com/sebastiencs/icons-in-terminal.git
cd icons-in-terminal/
./install.sh

#ranger plugins
#ranger icons
cd .config/ranger/plugins/
git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons

cd
git clone https://github.com/pipe99g/dotfiles
bash stow.sh

#default applications
handlr set inode/directory thunar.desktop

#El siguiente comando es redundante porque ohmyzsh pregunta si quiero hacer a zsh el shell predeterminado
#chsh -s $(which zsh)

#Para agregar LTS al GRUB (no sé si así funciona)
# sudo grub-mkconfig -o /boot/grub/grub.cfg
# sudo grub-install --efi-directory=/boot

#enable services
systemctl --user enable pipewire pipewire-pulse
systemctl enable paccache.timer
systemctl enable ufw.service
systemctl enable archlinux-keyring-wkd-sync.timer
systemctl enable cups.service
#si se usa ssd
systemctl enable fstrim.timer
