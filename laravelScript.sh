#!/bin/bash

clear
rm Vagrantfile ubuntu-xenial-16.04-cloudimg-console.log

#####

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

#####

echo "
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(\"2\") do |config|
  config.vm.box = \"laravel/homestead\"
  config.vm.network \"private_network\", ip: \"$ip\"
  config.vm.synced_folder \"./$file\", \"/var/www/html/\"
  config.vm.provider \"virtualbox\" do |v|
    v.name = \"$nom\"
  end
end
" >./Vagrantfile #Ficher de config de Vagrant

mkdir ./$file #Dossier sync

#####

wget https://github.com/vrana/adminer/releases/download/v4.7.1/adminer-4.7.1-mysql.php
mv adminer-4.7.1-mysql.php ./$file/adminer.php  #Installation de Adminer

#####

  echo "
  #!bin/bash

  sudo apt update
  sudo apt install apache2 -y
  sudo apt install libapache2-mod-php7.2 -y
  sudo sed -i '479s/Off/On/' /etc/php/7.2/apache2/php.ini
  sudo sed -i '490s/Off/On/' /etc/php/7.2/apache2/php.ini
  sudo sed -i '16s/var-www/vagrant/' /etc/apache2/envvars
  sudo sed -i '17s/var-www/vagrant/' /etc/apache2/envvars
  sed -i 's/\/var\/www\//\/var\/www\/laravel\/public/g' /etc/apache2/sites-available/000-default.conf
  sed -i '14i\    <Directory />\r' /etc/apache2/sites-available/000-default.conf
  sed -i '15i\                Options FollowSymLinks\r' /etc/apache2/sites-available/000-default.conf
  sed -i '16i\                AllowOverride All\r' /etc/apache2/sites-available/000-default.conf
  sed -i '17i\    </Directory>\r' /etc/apache2/sites-available/000-default.conf
  sed -i '18i\    <Directory /var/www/>\r' /etc/apache2/sites-available/000-default.conf
  sed -i '19i\                Options Indexes FollowSymLinks MultiViews\r' /etc/apache2/sites-available/000-default.conf
  sed -i '20i\                AllowOverride All\r' /etc/apache2/sites-available/000-default.conf
  sed -i '21i\                Order allow,deny\r' /etc/apache2/sites-available/000-default.conf
  sed -i '22i\                allow from all\r' /etc/apache2/sites-available/000-default.conf
  sed -i '23i\    </Directory>\r' /etc/apache2/sites-available/000-default.conf
  sudo a2enmod rewrite
  sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
  sudo service apache2 restart
  echo 'Plus qu\'a créer un projet avec composer create-project --prefer-dist laravel/laravel blog'
  rm /var/www/html/install.sh

  " >./$file/install.sh

#####

rm laravelScript.sh

vagrant up
vagrant ssh