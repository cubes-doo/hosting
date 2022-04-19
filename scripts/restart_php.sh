#!/bin/bash

DB_USER="user";
minimum_finds=30
found=$(mysql -u root -e 'SHOW FULL PROCESSLIST' | grep '$DB_USER' | grep -v 'Sleep' | wc -l)

if ((found >= minimum_finds)); then
  /etc/init.d/php7.4-fpm restart > /dev/null
fi
