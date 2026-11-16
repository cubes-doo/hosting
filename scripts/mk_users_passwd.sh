FTP_USER="User";
PASSWORD="Pass";
PASSWORD_FILE="users.passwd";
htpasswd -b -p $PASSWORD_FILE $FTP_USER `mkpasswd -5 $PASSWORD`
