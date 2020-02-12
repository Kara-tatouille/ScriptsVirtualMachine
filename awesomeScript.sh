#!/bin/bash

# # # # # # # # # # This script is awesome! # # # # # # # # # #

clear
rm Vagrantfile ubuntu-xenial-16.04-cloudimg-console.log

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo 'Voici une liste des VMs:'
vboxmanage list vms

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # Vieux trucs pour validation, inutile.
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

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

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

# # # # # # # # # # # # # # Core # # # # # # # # # # # # # # # # #

echo "...Création d'une nouvelle VM..."

echo 'ip de la VM à utiliser dans le navigateur? (192.168.33.XX) ' #Choix de l'ip du serveur
read -r ip
while [[ "$ip" != "192.168.33."* ]]; do #redemmande l'ip si elle est incorrecte
  echo 'ip doit être 192.168.33.XX, réentrer ip:'
  read -r ip
done
echo 'Quel nom de dossier sync? (ne rien mettre pour "Data")' #customise le nom du dossier de syncronisation de Vagrant
read -r file
echo $'Quel nom de \e[31mVM\e[0m? (ne rien mettre pour "Défaut")' #customise le nom de la VM et ajoute l'addresse ip du server à coté
read -r nom
nom="$nom - ip:$ip"

if [[ "$nom" == " - ip:$ip" ]]; then #Nom par défaut de la VM
  nom="Défaut-ip:$ip"
fi

if [[ "$file" == "" ]]; then #Nom par défaut du dossier de syncronisation de Vagrant
  file='data'
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

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
" > ./Vagrantfile #Ficher de config de Vagrant

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

mkdir ./${file} #Dossier sync

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Installation d'un gestionaire de base de donnée?"
select optSGBD in Adminer Phpmyadmin; do
  case $optSGBD in
  Adminer)
    echo 'Installation de Adminer..'
    wget -q https://github.com/vrana/adminer/releases/download/v4.7.1/adminer-4.7.1-mysql.php #Installation de Adminer
    mv adminer-4.7.1-mysql.php ./${file}/adminer.php
    echo 'Done!'
    ;;
  Phpmyadmin)
    echo 'Installation de PhpMyAdmin..'
    wget -q https://files.phpmyadmin.net/phpMyAdmin/4.9.4/phpMyAdmin-4.9.4-all-languages.tar.gz #Installation de Adminer
    mkdir ./${file}/phpmyadmin
    tar -zxf phpMyAdmin-4.9.4-all-languages.tar.gz -C ./${file}/phpmyadmin --strip-components 1
    rm -R phpMyAdmin-4.9.4-all-languages.tar.gz
    echo 'Done!'
    ;;
  esac
  break
done

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #Création du script d'installation une fois dans la VM

# shellcheck disable=SC2016
echo '
  #!/bin/bash

  echo "Choisis une version de PHP"
  select optPHP in php7.4 php7.3 php7.2 php5.6; do
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update
    sudo apt install apache2 -y
    sudo apt install ${optPHP} -y
    sudo apt install libapache2-mod-${optPHP} -y
    sudo apt install php-xdebug -y
    sudo apt install ${optPHP}-mysql -y
    sudo apt install ${optPHP}-zip -y
    sudo apt install ${optPHP}-mbstring -y
    sudo apt install ${optPHP}-dom -y
    sudo apt install ${optPHP}-curl -y
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password 1234"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 1234"
    sudo apt install mysql-server -y

    php -r "copy('\''https://getcomposer.org/installer'\'', '\''composer-setup.php'\'');"
    php composer-setup.php
    php -r "unlink('\''composer-setup.php'\'');"
    sudo mv composer.phar /usr/local/bin/composer

    case $optPHP in
    php5.6)
      sudo sed -i '\''466s/Off/On/'\'' /etc/php/5.6/apache2/php.ini
      sudo sed -i '\''477s/Off/On/'\'' /etc/php/5.6/apache2/php.ini
      sudo sed -i '\''16s/www-data/vagrant/'\'' /etc/apache2/envvars
      sudo sed -i '\''17s/www-data/vagrant/'\'' /etc/apache2/envvars
      ;;
    *)
      sudo sed -i '\''474s/Off/On/'\'' /etc/php/7.3/apache2/php.ini
      sudo sed -i '\''485s/Off/On/'\'' /etc/php/7.3/apache2/php.ini
      sudo sed -i '\''16s/www-data/vagrant/'\'' /etc/apache2/envvars
      sudo sed -i '\''17s/www-data/vagrant/'\'' /etc/apache2/envvars
      ;;
esac

    sudo a2enmod rewrite

    sudo service apache2 restart
    echo "Done! Ton mot de passe mysql est 1234, change le!"
    rm /var/www/html/install.sh
    break
  done
  ' > ./$file/install.sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

rm awesomeScript.sh

vagrant up
vagrant ssh
