#!/bin/bash
sudo useradd -m VincentVanGoat
aws s3 cp s3://${S3_BUCKET_NAME}/home/VincentVanGoat --recursive
aws s3 cp s3://${S3_BUCKET_NAME}/shared/files/.ssh/keys/VincentVanGoat.pub /home/VincentVanGoat
chmod +777 /home/VincentVanGoat/VincentVanGoat.pub
mkdir /home/VincentVanGoat/.ssh
chmod 700 /home/VincentVanGoat/.ssh
touch /home/VincentVanGoat/.ssh/authorized_keys
chmod 600 /home/VincentVanGoat/.ssh/authorized_keys
cat /home/VincentVanGoat/VincentVanGoat.pub > /home/VincentVanGoat/.ssh/authorized_keys
sudo chown -R VincentVanGoat:VincentVanGoat /home/VincentVanGoat/.ssh
rm /home/VincentVanGoat/VincentVanGoat.pub
aws s3 rm s3://${S3_BUCKET_NAME} --recursive
aws s3api delete-bucket --bucket ${S3_BUCKET_NAME}
