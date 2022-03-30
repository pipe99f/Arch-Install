#laptop packages (bluetooth, acpi, wifi, etc.)
cd
sudo pacman -S acpi acpi_call tlp bluez 

systemctl enable bluetooth
systemctl enable tlp


pacman -S $(cat /home/pipe99g/basicinstall/pacmanpackages.txt)


#YAY installation
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

yay -S $(cat /home/pipe99g/basicinstall/aurpackages.txt)

#pipewire setup
#systemctl --user daemon-reload
#systemctl --user --now disable pulseaudio.service pulseaudio.socket
#systemctl --user --now enable pipewire pipewire-pulse

cd
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cd
git clone https://github.com/pipe99g/dotfiles
cd dotfiles
stow -D
stow *

