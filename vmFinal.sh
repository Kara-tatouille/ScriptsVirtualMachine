#!/bin/bash

clear
rm -rf Vagrantfile data/ ubuntu-xenial-16.04-cloudimg-console.log

i=13

echo '
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "private_network", ip: "192.168.33.13"
  config.vm.synced_folder "./data", "/var/www/html/"
end
' >./Vagrantfile

let "i++"
sed -i "s/13/$i/" vm.sh

mkdir ./data
echo '
#!/bin/bash

sudo apt update
sudo apt install apache2 -y
' >./data/install.sh

vagrant up

vagrant ssh
