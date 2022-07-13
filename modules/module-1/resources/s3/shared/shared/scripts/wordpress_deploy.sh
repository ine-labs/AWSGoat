#!/bin/bash

sudo su

db_root_password=PassWord4-root
db_username=wordpress_user
db_user_password=PassWord4-user
db_name=wordpress_db


yum update -y
yum install -y httpd
 

amazon-linux-extras enable php7.4
yum clean metadata
yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel}

yum -y install gcc ImageMagick ImageMagick-devel ImageMagick-perl
pecl install imagick
chmod 755 /usr/lib64/php/modules/imagick.so
cat <<EOF >>/etc/php.d/20-imagick.ini

extension=imagick

EOF

systemctl restart php-fpm.service


yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum localinstall -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
yum install -y mysql-community-server



systemctl start  httpd
systemctl start mysqld


usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;


wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/


chown  ec2-user:apache /var/log/mysqld.log
temppassword=$(grep 'temporary password' /var/log/mysqld.log | grep -o ".\{12\}$")
chown  mysql:mysql /var/log/mysqld.log


mysql -p$temppassword --connect-expired-password  -e "SET PASSWORD FOR root@localhost = PASSWORD('$db_root_password');FLUSH PRIVILEGES;" 
mysql -p'$db_root_password'  -e "DELETE FROM mysql.user WHERE User='';"
mysql -p'$db_root_password' -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

mysql -u root -p"$db_root_password" -e "GRANT ALL PRIVILEGES ON *.* TO '$db_username'@'localhost' IDENTIFIED BY '$db_user_password';FLUSH PRIVILEGES;"


mysql -u $db_username -p"$db_user_password" -e "CREATE DATABASE $db_name;"

cd /var/www/html
cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/$db_name/g" wp-config.php
sed -i "s/username_here/$db_username/g" wp-config.php
sed -i "s/password_here/$db_user_password/g" wp-config.php
cat <<EOF >>/var/www/html/wp-config.php

define( 'FS_METHOD', 'direct' );
define('WP_MEMORY_LIMIT', '256M');
EOF


chown -R ec2-user:apache /var/www/html
chmod -R 774 /var/www/html

sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf

systemctl enable  httpd.service
systemctl enable mysqld.service
systemctl restart httpd.service