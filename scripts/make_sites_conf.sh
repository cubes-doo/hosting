#! /bin/bash

DOMAIN="mydomain.com"


mkdir -p /var/www/$DOMAIN
mkdir -p /var/www/$DOMAIN/www-root && mkdir -p /var/www/$DOMAIN/logs
touch /var/www/$DOMAIN/logs/.borgignore
mkdir -p /var/www/$DOMAIN/www-root/public
chown -R cubes: /var/www/$DOMAIN/www-root

touch /etc/nginx/sites-available/$DOMAIN.conf
wget -O /etc/nginx/sites-available/$DOMAIN.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nginx/sites-available/laravel.conf

sed -i 's/WEBSITE/mydomain.com/' /etc/nginx/sites-available/$DOMAIN.conf
sed -i 's/www.WEBSITE/www.mydomain.com/' /etc/nginx/sites-available/$DOMAIN.conf
cd /etc/nginx/sites-enabled
ln -s ../sites-available/$DOMAIN.conf
systemctl reload nginx
