apt-get -y update
apt-get -y upgrade
apt-get -y install locales-all

#SSH

wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/ssh/sshd_config
systemctl restart sshd

#OLS

wget https://openlitespeed.org/packages/openlitespeed-1.7.16.tgz
tar -zxvf openlitespeed-*.tgz
cd openlitespeed
./install.sh
/usr/local/lsws/bin/lswsctrl status
/usr/local/lsws/bin/lswsctrl start
/usr/local/lsws/admin/misc/admpass.sh
user: cubes / passwowd: CUBols!@#

#Lsphp

apt-get install -y lsphp74-{amqp,bcmath,bz2,cli,common,amqp,bcmath,bz2,cli,common,curl,dev,fpm,gd,http,igbinary,imagick,imap,intl,ldap,mbstring,memcache,memcached,mongodb,mysql,oauth,odbc,opcache,phpdbg,readline,redis,soap,solr,sqlite3,ssh2,uploadprogress,uuid,xdebug,xml,xmlrpc,xsl,yaml,zi,pro,raphf} 

#Mysql

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

#Phpmyadmin

cd /usr/local/lsws/Example/html
wget -q https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip
unzip phpMyAdmin-latest-all-languages.zip
rm phpMyAdmin-latest-all-languages.zip
mv phpMyAdmin-*-all-languages phpmyadmin
mv phpmyadmin/config.sample.inc.php phpmyadmin/config.inc.php

#Vsftp

apt-get -y install vsftpd libpam-pwdfile apache2-utils whois
mkdir -p /etc/vsftpd/users
wget -O /etc/vsftpd.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/vsftpd/vsftpd.conf
wget -O /etc/pam.d/vsftpd https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/vsftpd/pam.d/vsftpd
wget -O /etc/vsftpd/ftp_users_passwd.sh https://raw.githubusercontent.com/cubes-doo/hosting/master/scripts/ftp_users_passwd.sh
chmod +x /etc/vsftpd/ftp_users_passwd.sh
touch /etc/vsftpd/users.passwd
systemctl enable vsftpd
systemctl restart vsftpd

#Nftables

apt-get -y install nftables
wget -O /etc/nftables.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nftables/nftables.conf
systemctl enable nftables
systemctl restart nftables

#Zabbix

wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-1+debian10_all.deb
dpkg -i zabbix-release_6.0-1+debian10_all.deb
apt-get -y update
apt-get -y install zabbix-agent
mkdir /var/lib/zabbix
echo -e "[client]\nuser='zabbix'\npassword='********'\n" > /var/lib/zabbix/.my.cnf
chown -R zabbix: /var/lib/zabbix
wget -O /etc/zabbix/zabbix_agentd.d/template_db_mysql.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/zabbix/zabbix_agentd.d/template_db_mysql.conf
systemctl restart zabbix-agent

#Certbot

apt-get -y update
apt-get -y install snapd
snap install core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

#OLS Server Configuration

Server Configuration > External App

Name: lsphp74 #lsphp_version_of_php
Address: uds://tmp/lshttpd/lsphp.sock
Max Connections: 1000
Environmen: PHP_LSAPI_CHILDREN=100
            LSAPI_AVOID_FORK=200M
            PHP_LSAPI_MAX_REQUESTS=500
            LSAPI_PGRP_MAX_IDLE=10
            LSAPI_AVOID_FORK=1

Initial Request Timeout (secs): 60
Retry Timeout (secs): 0
Persistent Connection: yes
Connection Keep-Alive Timeout: 60
Command: lsphp74/bin/lsphp

Server Configuration > Modules

Module: Cache 
Module Parameters: 
                  checkPrivateCache   1
                  checkPublicCache    1
                  maxCacheObjSize     10000000
                  maxStaleAge         200
                  qsCache             1
                  reqCookieCache      1
                  respCookieCache     1
                  ignoreReqCacheCtrl  1
                  ignoreRespCacheCtrl 0
                  
                  enableCache         1
                  expireInSeconds     300
                  enablePrivateCache  0
                  privateExpireInSeconds 300

#OLS Virtual Host

Virtual Host > Basic

Virtual Host Name: name_site
Virtual Host Root: $SERVER_ROOT/vhosts/name_site
Config File: $SERVER_ROOT/conf/vhosts/name_site/vhconf.conf

Virtual Host > Genaral

Document Root: $SERVER_ROOT/vhosts/name_site/www-root/public
Domain Name: name_site
Domain Aliases: www.name_site
Enable GZIP Compression: Yes
Enable Brotli Compression:	Yes
Enable GeoLocation Lookup:	Yes
cgroups:	Off

Virtual Host > Index Files

Use Server Index Files:	No
Index Files:	index.php, index.html
Auto Index:	Yes

Virtual Host > Log

Virtual Host Log

Use Server's Log:	No
File Name:	/usr/local/lsws/vhosts/name_site/logs/error.log
Log Level:	WARNING
Rolling Size (bytes):	100M
Keep Days:	30
Compress Archive:	Yes

Access Log

Log Control: Own log files
File Name: /usr/local/lsws/vhosts/name_site/logs/access.log
Log Headers: Referrer, UserAgent, Host   
Rolling Size (bytes): 100M
Keep Days: 30
Compress Archive: Yes

Virtual Host > Rewrite

Rewrite Control

Enable Rewrite:	Yes
Auto Load from .htaccess:	Yes

Virtual Host > SSL

SSL Private Key & Certificate

Private Key File:	/etc/letsencrypt/live/srpskainfo.com/privkey.pem
Certificate File:	/etc/letsencrypt/live/srpskainfo.com/fullchain.pem
Chained Certificate: Yes

#OLS  Listener

Listener HTTPS > General

Address Settings
Listener Name: HTTPS
IP Address:	ANY IPv4
Port:	443
Secure:	Yes

Virtual Host Mappings
Virtual Host: name_site
Domains: name_site, www.name_site

Listener HTTPS > SSL

SSL Private Key & Certificate
Private Key File:	/usr/local/lsws/ssl/server-key.pem
Certificate File:		/usr/local/lsws/ssl/server-cert.pem
Chained Certificate: Yes

Listener HTTP > General

Address Settings
Listener Name: HTTP
IP Address:	ANY IPv4
Port:	80
Secure: No

Virtual Host Mappings
Virtual Host: name_site
Domains: name_site

WP-Cli 

ln -s /usr/local/lsws/lsphp74/bin/php /usr/local/bin/php7.4
