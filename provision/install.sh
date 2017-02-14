#!/bin/bash

echo "[[ Removing prompts ]]"
export DEBIAN_FRONTEND="noninteractive"
sudo usermod -a -G ubuntu www-data

echo "[[ Updating system ]]"
sudo apt-get -yqq update
sudo apt-get -yqq install language-pack-en expect wget vim zip curl php-curl

echo "[[ Installing mysql-server ]]"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
sudo apt-get -yqq install mysql-server
expect -f - <<-EOF
  set timeout 10
  spawn mysql_secure_installation
  expect "Enter password for user root:"
  send -- "root\r"
  expect "VALIDATE PASSWORD PLUGIN can be used to test passwords"
  send -- "n\r"
  expect "Change the password for root ?"
  send -- "n\r"
  expect "Remove anonymous users?"
  send -- "y\r"
  expect "Disallow root login remotely?"
  send -- "y\r"
  expect "Remove test database and access to it?"
  send -- "y\r"
  expect "Reload privilege tables now?"
  send -- "y\r"
  expect eof
EOF

echo "[[ Installing and configuring nginx ]]"
sudo apt-get -yqq install nginx
sudo service nginx start
sudo sed -i 's/sendfile on;/sendfile off;/g' /etc/nginx/nginx.conf
sudo cp /vagrant/provision/nginx/sites-available/vhost /etc/nginx/sites-available/vhost
rm -rf /etc/nginx/sites-enabled/vhost
sudo ln -s /etc/nginx/sites-available/vhost /etc/nginx/sites-enabled/vhost
sudo rm -rf /var/www
sudo ln -s /vagrant /var/www
sudo service nginx restart

echo "[[ Installing and configuring PHP ]]"
sudo apt-get -yqq install php-fpm php-mysql php-gd php7.0-gd php-imagick sed php7.0-xml
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.0/fpm/php.ini
sudo sed -i 's/;opcache.enable=0/opcache.enable=0/g' /etc/php/7.0/fpm/php.ini
sudo systemctl restart php7.0-fpm
sudo systemctl reload nginx

if [ ! -f /usr/local/bin/wp ]; then
    echo "[[ Installing WP-CLI ]]"
    cd /tmp
    curl -s -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
fi

echo "[[ Create WordPress database ]]"
expect -f - <<-EOF
    set timeout 10
    spawn sh -c "mysql -u root -p < /vagrant/provision/database.sql"
    expect "Enter password:"
    send -- "root\r"
    expect eof
EOF

echo "[[ Create public folder for WordPress install ]]"
if [ ! -d /vagrant/public ]; then
    cd /vagrant
    mkdir public
fi

cd /vagrant/public
if ! $(sudo -u ubuntu -H wp core is-installed); then
    echo "[[ Installing WordPress with WP-CLI ]]"
    sudo -u ubuntu -H wp core download --path=/vagrant/public --locale=en_US --version=latest
    sudo -u ubuntu -H wp core config --dbname=wordpress --dbuser=wordpress --dbpass=wordpress
    sudo -u ubuntu -H wp core install --url=$1 --title="$2" --admin_user=admin --admin_password=admin --admin_email='your.email@example.com' --skip-email
fi
