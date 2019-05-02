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

# # # # # # # # # # # # # # Core # # # # # # # # # # # # # # # # # 

echo "...Création d'une nouvelle VM..."

echo 'Quelle ip?' #Choix de l'ip du serveur
  read ip
while [[ "$ip" != "192.168.33."* ]]; do #redemmande l'ip si elle est incorrecte
  echo 'ip doit être 192.168.33.XX, réentrer ip:'
  read ip
done
echo 'Quel nom de dossier sync? (ne rien mettre pour "Data")' #customise le nom du dossier de syncronisation de Vagrant
  read file
echo 'Quel nom de VM? (ne rien mettre pour "Défaut")' #customise le nom de la VM et ajoute l'addresse ip du server à coté
  read nom
  nom="$nom - ip:$ip"


if [[ "$nom" = " - ip:$ip" ]]; then #Nom par défaut de la VM
  nom="Défaut-ip:$ip"
fi

if [[ "$file" = "" ]]; then #Nom par défaut du dossier de syncronisation de Vagrant
  file='data'
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
" >./Vagrantfile #Ficher de config de Vagrant

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

mkdir ./$file #Dossier sync

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

wget https://github.com/vrana/adminer/releases/download/v4.7.1/adminer-4.7.1-mysql.php #Installation de Adminer
mv adminer-4.7.1-mysql.php ./$file/adminer.php


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #Création du script d'installation une fois dans la VM

#todo: choix de la version PHP


# echo 'Veuillez choisir une version de PHP: (défaut 7.2)  (7.0)' #Choix de la version de PHP
# read phpVersion

# while [[ $phpVersion != '7.2' || $phpVersion != '7.0' || $phpVersion != '' ]]; do #Si le choix n'est pas reconnu, redemmander une bonne valeur
#   echo 'Valeur incorrecte, réentrer la version de PHP: (défaut 7.2)  (7.0)'
#   read phpVersion
# done

# if [[ $phpVersion = '7.2' || $phpVersion = '' ]]; then #Création du script pour PHP7.2 (choix par défaut)
  echo "
  #!bin/bash

  sudo add-apt-repository ppa:ondrej/php -y
  sudo apt update
  sudo apt install apache2 -y
  sudo apt install php7.2 -y
  sudo apt install libapache2-mod-php7.2 -y
  sudo apt install php7.2-mysql -y
  sudo sed -i '479s/Off/On/' /etc/php/7.2/apache2/php.ini
  sudo sed -i '490s/Off/On/' /etc/php/7.2/apache2/php.ini
  sudo apt install mysql-server -y
  sudo service apache2 restart
  " >./$file/install.sh
# elif [[ $phpVersion = '7.0' ]]; then #Création du script pour PHP7.0
#   echo "
#   #!bin/bash

#   sudo add-apt-repository ppa:ondrej/php -y
#   sudo apt update
#   sudo apt install apache2 -y
#   sudo apt install php7.0 -y
#   sudo apt install libapache2-mod-php7.0 -y
#   sudo apt install php7.0-mysql -y
#   sudo sed -i '479s/Off/On/' /etc/php/7.0/apache2/php.ini
#   sudo sed -i '490s/Off/On/' /etc/php/7.0/apache2/php.ini 
#   sudo apt install mysql-server -y
#   sudo service apache2 restart
#   " >./$file/install.sh #sed à changer!! ne marche pas pour l'instant
# else echo 'Big bug, pls contact Corenbla' #Si jamais $phpVersion a buggé
# fi



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

vagrant up
vagrant ssh