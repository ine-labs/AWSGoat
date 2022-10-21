#!/bin/bash
mysql -h $RDS_ENDPOINT -P 3306 -u root -pT2kVB3zgeN3YbrKS -e "source /var/www/html/dump.sql" > /dev/null 2>&1
sed -i "s,RDS_ENDPOINT_VALUE,$RDS_ENDPOINT,g" /var/www/html/config.inc
exec apache2-foreground