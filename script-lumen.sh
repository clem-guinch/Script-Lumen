#!/bin/bash
# Créer le vagrantfile
# Demander infos 1.Choisir l'adresseIp / 2.Nom du dossier partagé à créer
# Remplir le vagrantfile
# Vagrant up
# Vagrant ssh
echo "Création du fichier vagrant"
touch Vagrantfile
echo "Choisssez la fin de votre adresse ip :"
read -p "192.168.33." ip
echo "Choisissez votre nom de dossier partagé"
read -p "./" dir

cat > vagrantfile << eof
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
config.vm.box = "ubuntu/xenial64"
config.vm.network "private_network", ip: "192.168.33.$ip"
config.vm.synced_folder "./$dir", "/var/www/html"
end
eof

mkdir $dir

cd $dir

cat > lumen_install.sh << eof
#!/bin/bash
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt install apache2 php7.2 mysql-server libapache2-mod-php7.2 -y
sudo apt install php7.2-mysql
rm index.html
sudo apt install zip php7.2-zip -y
sudo sed -i "477s/display_errors = Off/display_errors = On/g" /etc/php/7.2/apache2/php.ini
sudo sed -i "488s/display_startup_errors = Off/display_startup_errors = On/g" /etc/php/7.2/apache2/php.ini
sudo sed -i "16s/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=vagrant/g" /etc/apache2/envvars
sudo sed -i "17s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=vagrant/g" /etc/apache2/envvars
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
composer require guzzlehttp/guzzle
sudo apt install php7.2-dom -y
sudo apt install php7.2-mbstring -y
composer create-project --prefer-dist laravel/lumen lumenAPI
sudo a2enmod rewrite
sudo sed -i "12s/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/lumenAPI\/public/g" /etc/apache2/sites-available/000-default.conf
sudo sed -i "13c\ \t<Directory /var/www/html/lumenAPI/public>\n\t\tOptions Indexes FollowSymLinks MultiViews\n\t\tAllowOverride All\n\t\tOrder allow,deny\n\t\tallow from all\n\\t<\/Directory\>" /etc/apache2/sites-available/000-default.conf
sudo service apache2 restart
end
eof


cd ../
vagrant up
vagrant ssh
