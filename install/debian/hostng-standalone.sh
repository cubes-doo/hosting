apt-get -y update
apt-get -y upgrade
apt-get -y install locales-all

wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/ssh/sshd_config
systemctl restart sshd

timedatectl set-timezone Europe/Belgrade

apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/99nginx
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

apt-get -y install lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list
curl -fsSL  https://packages.sury.org/php/apt.gpg| gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-keyring.gpg
apt-get -y update
apt-get install -y php7.4-{amqp,bcmath,bz2,cli,common,amqp,bcmath,bz2,cli,common,curl,dev,fpm,gd,http,igbinary,imagick,imap,intl,ldap,mbstring,memcache,memcached,mongodb,mysql,oauth,odbc,opcache,phpdbg,readline,redis,soap,solr,sqlite3,ssh2,uploadprogress,uuid,xdebug,xml,xmlrpc,xsl,yaml,zi,pro,raphf}
wget -O /etc/php/7.4/fpm/pool.d/www.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/php7.4/fpm/pool.d/www.conf
mkdir /var/log/php7.4-fpm
systemctl enable php7.4-fpm
systemctl restart php7.4-fpm

apt-get -y install curl apt-transport-https wget -y
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup
./mariadb_repo_setup --mariadb-server-version="mariadb-10.5"
apt-get -y update
apt-get -y install mariadb-server mariadb-backup
wget -O /etc/mysql/my.cnf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/mysql/my.cnf
wget -O /etc/mysql/mariadb.conf.d/99-performance-tunning.cnf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/mysql/mariadb.conf.d/99-performance-tunning.cnf
systemctl enable mariadb
systemctl restart mariadb
mysql -e "CREATE USER 'phpmyadmin'@'%' IDENTIFIED BY '********';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'%' WITH GRANT OPTION;"
mysql -e "CREATE USER 'zabbix'@'%' IDENTIFIED BY '********';"
mysql -e "GRANT PROCESS, SHOW DATABASES, REPLICATION CLIENT, SHOW VIEW ON *.* TO 'zabbix'@'%';"
mysql -e "CREATE USER backup@localhost IDENTIFIED BY 'CUBbackup';"
mysql -e "GRANT SELECT, RELOAD, SHOW DATABASES, LOCK TABLES, REPLICATION CLIENT, SHOW VIEW, TRIGGER ON *.* TO 'backup'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz
tar -xzf phpMyAdmin-5.2.1-all-languages.tar.gz
mv phpMyAdmin-5.2.1-all-languages /usr/share/phpmyadmin
rm phpMyAdmin-5.2.1-all-languages.tar.gz
wget -O /usr/share/phpmyadmin/config.inc.php https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/phpmyadmin/config.inc.php
wget -O /etc/nginx/conf.d/phpmyadmin.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nginx/conf.d/phpmyadmin.conf
mkdir /usr/share/phpmyadmin/tmp
chmod 777 /usr/share/phpmyadmin/tmp
systemctl reload nginx

apt-get -y install vsftpd libpam-pwdfile apache2-utils whois
mkdir -p /etc/vsftpd/users
wget -O /etc/vsftpd.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/vsftpd/vsftpd.conf
wget -O /etc/pam.d/vsftpd https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/vsftpd/pam.d/vsftpd
wget -O /etc/vsftpd/ftp_users_passwd.sh https://raw.githubusercontent.com/cubes-doo/hosting/master/scripts/ftp_users_passwd.sh
chmod +x /etc/vsftpd/ftp_users_passwd.sh
touch /etc/vsftpd/users.passwd
systemctl enable vsftpd
systemctl restart vsftpd
sed -i 's/User/USER/' /etc/vsftpd/ftp_users_passwd.sh && sed -i 's/Pass/********/' /etc/vsftpd/ftp_users_passwd.sh
. /etc/vsftpd/ftp_users_passwd.sh

apt-get -y install nftables
wget -O /etc/nftables.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nftables/nftables.conf
systemctl enable nftables
systemctl restart nftables

wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_latest+debian12_all.deb
dpkg -i zabbix-release_latest+debian12_all.deb
apt-get -y update
apt-get -y install zabbix-agent
mkdir /var/lib/zabbix
echo -e "[client]\nuser='zabbix'\npassword='********'\n" > /var/lib/zabbix/.my.cnf
chown -R zabbix: /var/lib/zabbix
wget -O /etc/zabbix/zabbix_agentd.d/template_db_mysql.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/zabbix/zabbix_agentd.d/template_db_mysql.conf
systemctl restart zabbix-agent

wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-1+debian10_all.deb
dpkg -i zabbix-release_6.0-1+debian10_all.deb
apt-get -y update
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
mysql -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
mysql -e "create user zabbix@localhost identified by '********';"
mysql -e "grant all privileges on zabbix.* to zabbix@localhost;"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix -p zabbix
wget -O /etc/zabbix/zabbix_server.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/zabbix/zabbix_server.conf 
sed -i 's/MYSQL_ZABBIX_PWD/*******/' /etc/zabbix/zabbix_server.conf
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

apt-get -y update
apt-get -y install snapd
snap install core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
