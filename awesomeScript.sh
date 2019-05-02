#!/bin/bash

# # # # # # # # # # This script is awesome! # # # # # # # # # # 

clear
rm Vagrantfile ubuntu-xenial-16.04-cloudimg-console.log

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo 'Voici une liste des VMs:'
vboxmanage list vms

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # Vieux trucs pour validation, inutile.
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

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #Core, création de Vagrantfile, dossier sync et config de l'ip

echo "...Création d'une nouvelle VM..."

echo 'Quelle ip?'
  read ip
while [[ "$ip" != "192.168.33."* ]]; do
  echo 'ip doit être 192.168.33.XX, réentrer ip:'
  read ip
done
echo 'Quel nom de dossier sync? (ne rien mettre pour "Data")'
  read file
echo 'Quel nom de VM? (ne rien mettre pour "Défaut")'
  read nom
  nom="$nom - ip:$ip"


if [[ "$nom" = " - ip:$ip" ]]; then
  nom="Défaut-ip:$ip"
fi

if [[ "$file" = "" ]]; then
  file=data
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #Vagrantfile

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

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #Dossier sync

mkdir ./$file

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #Installation de Adminer

wget https://github.com/vrana/adminer/releases/download/v4.7.1/adminer-4.7.1-mysql.php
mv adminer-4.7.1-mysql.php ./$file/adminer.php


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #Création du script d'installation une fois dans la VM

echo "
#!bin/bash

sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install apache2 -y
sudo apt install php7.2 -y
sudo apt install libapache2-mod-php7.2 -y
sudo apt install php7.2-mysql -y
sudo apt install mysql-server -y
sudo sed -i '479s/Off/On/' /etc/php/7.2/apache2/php.ini
sudo sed -i '490s/Off/On/' /etc/php/7.2/apache2/php.ini
sudo service apache2 restart
" >./$file/install.sh



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

vagrant up
vagrant ssh