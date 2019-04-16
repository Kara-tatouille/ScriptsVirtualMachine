#!/bin/bash

# # # # # # # # # # This script is awesome! # # # # # # # # # # 

clear
rm -rf Vagrantfile ubuntu-xenial-16.04-cloudimg-console.log

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo 'Voici une liste des VMs:'
vboxmanage list vms --long | grep -e "Name:" -e "State:"

#echo 'Veux tu allumer une VM? 1)Oui 2)Non'
#select opt in Oui Non
#do
#        case $opt in
#        'Oui')  echo 'Rentrer le nom de la VM à allumer'
#                VBoxManage list vms
#                read choix
#                 VBoxManage startvm "$choix"
#                ;;
#        'Non') break
#                ;;
#        esac
#	break
#done

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#echo 'Veux tu éteindre une VM?'
#select opt2 in Oui Non
#do
#	case $opt2 in
#	'Oui')	echo 'Rentrer le nom de la VM à éteindre'
#		VBoxManage list vms
#		read choix2
#		VBoxManage controlvm "$choix2" poweroff
#		;;
#	'Non') break
#		;;
#	esac
#	break
#done

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "...Création d'une nouvelle VM..."

echo 'Quelle ip?'
  read ip
echo 'Quel nom de dossier sync? (ne rien mettre pour un nom par défaut)'
  read file
echo 'Quel nom de VM? (ne rien mettre pour un nom par défaut)'
  read nom


while [[ "$ip" != "192.168.33."* ]]; do
  echo 'Mauvaise ip, réentrer ip:'
  read ip
done

if [[ "$nom" = "" ]]; then
  nom=Default
fi

if [[ "$file" = "" ]]; then
  file=default
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(\"2\") do |config|
  config.vm.box = \"ubuntu/xenial64\"
  config.vm.network \"private_network\", ip: \"$ip\"
  config.vm.synced_folder \"./$file\", \"/var/www/html/\"
  config.vm.provider \"virtualbox\" do |v|
    v.name = \"$nom\"
  end
end
" >./Vagrantfile

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

mkdir ./$file

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo '
#!bin/bash

sudo apt update
sudo apt install apache2 -y
' >./$file/install.sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

vagrant up
rm -rf ubuntu-xenial-16.04-cloud-img-console.log
vagrant ssh
