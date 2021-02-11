apt-get -y update
apt-get -y upgrade
apt-get -y install locales-all
apt-get -y install apt-transport-https lsb-release ca-certificates curl
curl -sSL -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt-get update
apt-get -y install php7.4 php7.4-amqp php7.4-bcmath php7.4-bz2 php7.4-cli php7.4-common php7.4-curl php7.4-dev php7.4-fpm php7.4-gd php7.4-http php7.4-igbinary php7.4-imagick php7.4-imap php7.4-intl php7.4-json php7.4-ldap php7.4-mbstring php7.4-memcache php7.4-memcached php7.4-mongodb php7.4-mysql php7.4-oauth php7.4-odbc php7.4-opcache php7.4-phpdbg php7.4-psr php7.4-readline php7.4-redis php7.4-soap php7.4-solr php7.4-sqlite3 php7.4-ssh2 php7.4-uploadprogress php7.4-uuid php7.4-xdebug php7.4-xml php7.4-xmlrpc php7.4-xsl php7.4-yaml php7.4-zip
systemctl enable php7.4-fpm
apt-get -y install curl gnupg2 ca-certificates lsb-release
echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" \
    | tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
apt-get update
apt-get -y install nginx
systemctl enable nginx
mkdir /etc/nginx/sites-available
mkdir /etc/nginx/sites-enabled
mkdir /etc/nginx/ssl
openssl req -nodes -subj "/C=RS/ST=Serbial/L=Belgrade/O=Cubes/CN=www.cubes.rs" -x509 -newkey rsa:4096 -keyout /etc/nginx/ssl/server-key.pem -out /etc/nginx/ssl/server-cert.pem -days 3650
