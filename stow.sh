#!/bin/bash


##primero verifica qué hay repetido
#la idea sería hacer algo tipo if .bashrc, then mv .bashrc .bashrcold
#pero en un loop para que verifique cada dotfile

cd ~/dotfiles
stow *

###sería bueno agregarle una opción para desinstalar y que devuelva los nombres originales a los archivos viejos 

#stow -D
#if *old, then ....


