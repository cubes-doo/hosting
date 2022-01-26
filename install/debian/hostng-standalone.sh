apt-get -y update
apt-get -y upgrade
apt-get -y install locales-all

wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/ssh/sshd_config
systemctl restart sshd

apt-get -y install apt-transport-https lsb-release ca-certificates curl
curl -sSL -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt-get -y update
apt-get -y install php7.4-amqp php7.4-bcmath php7.4-bz2 php7.4-cli php7.4-common 
apt-get -y install php7.4-curl php7.4-dev php7.4-fpm php7.4-gd php7.4-http php7.4-igbinary 
apt-get -y install php7.4-imagick php7.4-imap php7.4-intl php7.4-json php7.4-ldap php7.4-mbstring 
apt-get -y install php7.4-memcache php7.4-memcached php7.4-mongodb php7.4-mysql php7.4-oauth 
apt-get -y install php7.4-odbc php7.4-opcache php7.4-phpdbg php7.4-psr php7.4-readline php7.4-redis 
apt-get -y install php7.4-soap php7.4-solr php7.4-sqlite3 php7.4-ssh2 php7.4-uploadprogress 
apt-get -y install php7.4-uuid php7.4-xdebug php7.4-xml php7.4-xmlrpc php7.4-xsl php7.4-yaml php7.4-zip
apt-get -y install php7.4-propro php7.4-raphf
apt-get -y install php7.4-mysql
wget -O /etc/php/7.4/fpm/pool.d/www.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/php/fpm/pool.d/www.conf
systemctl enable php7.4-fpm
systemctl restart php7.4-fpm

apt-get -y install curl gnupg2 ca-certificates lsb-release
echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
apt-get -y update
apt-get -y install nginx
systemctl enable nginx
mkdir /etc/nginx/sites-available
mkdir /etc/nginx/sites-enabled
mkdir /etc/nginx/ssl
openssl req -nodes -subj "/C=RS/ST=Serbial/L=Belgrade/O=Cubes/CN=www.cubes.rs" -x509 -newkey rsa:4096 -keyout /etc/nginx/ssl/server-key.pem -out /etc/nginx/ssl/server-cert.pem -days 3650
wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nginx/nginx.conf
wget -O /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nginx/conf.d/default.conf
wget -O /etc/nginx/conf.d/status.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nginx/conf.d/status.conf
wget -O /etc/nginx/conf.d/fastcgi_cache.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nginx/conf.d/fastcgi_cache.conf
wget -O /usr/share/nginx/html/index.html https://raw.githubusercontent.com/cubes-doo/hosting/master/files/index.html
echo -e "\ntmpfs /var/cache/nginx tmpfs defaults,size=4G 0 0\n" >> /etc/fstab
mount /var/cache/nginx
systemctl restart nginx

apt-get -y install mariadb-server
wget -O /etc/mysql/my.cnf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/mysql/my.cnf
wget -O /etc/mysql/mariadb.conf.d/99-performance-tunning.cnf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/mysql/mariadb.conf.d/99-performance-tunning.cnf
systemctl enable mariadb
systemctl restart mariadb
mysql -e "CREATE USER 'phpmyadmin'@'%' IDENTIFIED BY '********';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'%' WITH GRANT OPTION;"
mysql -e "CREATE USER 'zabbix'@'%' IDENTIFIED BY '********';"
mysql -e "GRANT PROCESS, SHOW DATABASES, REPLICATION CLIENT, SHOW VIEW ON *.* TO 'zabbix'@'%'"
mysql -e "CREATE USER backup@localhost IDENTIFIED BY 'CUBbackup';"
mysql -e "GRANT SELECT, RELOAD, SHOW DATABASES, LOCK TABLES, REPLICATION CLIENT, SHOW VIEW, TRIGGER ON *.* TO 'backup'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

wget https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-all-languages.tar.gz
tar -xzf phpMyAdmin-5.1.1-all-languages.tar.gz
mv phpMyAdmin-5.1.1-all-languages /usr/share/phpmyadmin
rm phpMyAdmin-5.1.1-all-languages.tar.gz
wget -O /usr/share/phpmyadmin/config.inc.php https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/phpmyadmin/config.inc.php
wget -O /etc/nginx/conf.d/phpmyadmin.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nginx/conf.d/phpmyadmin.conf
mkdir /usr/share/phpmyadmin/tmp
chmod 777 /usr/share/phpmyadmin/tmp

apt-get -y install vsftpd libpam-pwdfile apache2-utils whois
mkdir -p /etc/vsftpd/users
wget -O /etc/vsftpd.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/vsftpd/vsftpd.conf
wget -O /etc/pam.d/vsftpd https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/vsftpd/pam.d/vsftpd
wget -O /etc/vsftpd/ftp_users_passwd.sh https://raw.githubusercontent.com/cubes-doo/hosting/master/scripts/ftp_users_passwd.sh
chmod +x /etc/vsftpd/ftp_users_passwd.sh
touch /etc/vsftpd/users.passwd
systemctl enable vsftpd
systemctl restart vsftpd
sed -i 's/User/USER/' /etc/vsftpd/ftp_users_passwd.sh && sed -i 's/Pass/********/' /etc/vsftpd/ftp_users_passwd.sh && . /etc/vsftpd/ftp_users_passwd.sh

apt-get -y install nftables
wget -O /etc/nftables.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nftables/nftables.conf
systemctl enable nftables
systemctl restart nftables


wget https://repo.zabbix.com/zabbix/5.0/debian/pool/main/z/zabbix-release/zabbix-release_5.0-1+buster_all.deb
dpkg -i zabbix-release_5.0-1+buster_all.deb
apt-get -y update
apt-get -y install zabbix-agent
mkdir /var/lib/zabbix
echo -e "[client]\nuser='zabbix'\npassword='********'\n" > /var/lib/zabbix/.my.cnf
chown -R zabbix: /var/lib/zabbix
wget -O /etc/zabbix/zabbix_agentd.d/template_db_mysql.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/zabbix/zabbix_agentd.d/template_db_mysql.conf
systemctl restart zabbix-agent
