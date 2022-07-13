#!/bin/bash

sudo adduser bob
sudo su - bob
mkdir .ssh
chmod 700 .ssh
touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
aws s3 cp s3://BUCKET/keys/bob.pem ./
cat bob.pem > .ssh/authorized_keys

sudo yum install -y gcc-c++ make 
curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash - 
sudo yum install -y nodejs 

sudo yum update -y
sudo yum install git -y

git clone https://github.com/GermaVinsmoke/bmi-calculator.git
cd bmi-calculator
npm install

npm run build

sudo su
yum update -y
yum install -y httpd php
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

cp -r build/* /var/www/html/
mkdir /var/www/html/bmi-calculator
mv /var/www/html/static  /var/www/html/bmi-calculator
systemctl restart httpd.service
