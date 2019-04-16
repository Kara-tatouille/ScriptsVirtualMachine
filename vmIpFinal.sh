
#!/bin/bash

###

clear
rm -rf Vagrantfile data/ ubuntu-xenial-16.04-cloudimg-console.log

###

echo 'Quel ip?'
  read ip
echo 'Quel nom?'
  read nom

if [[ $nom -eq '' ]]; then
  nom=default
fi

###

echo "
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(\"2\") do |config|
  config.vm.box = \"ubuntu/xenial64\"
  config.vm.network \"private_network\", ip: \"$ip\"
  config.vm.synced_folder \"./data\", \"/var/www/html/\"
  config.vm.provision \"shell\", inline: <<-SHELL
    apt-get update
    apt-get install -y apache2
  SHELL
  config.vm.provider \"virtualbox\" do |v|
    v.name = \"$nom\"
  end
end
" >./Vagrantfile

###

mkdir ./data

###

#echo '
# #!/bin/bash

#sudo apt update
#sudo apt install apache2 -y
#' >./data/install.sh

###

vagrant up

###

vagrant ssh
