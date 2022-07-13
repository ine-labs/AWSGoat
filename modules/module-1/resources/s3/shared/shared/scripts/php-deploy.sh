#!/bin/bash
yum update -y
yum install -y httpd php
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
# PHP script to display Instance ID and Availability Zone
cat << 'EOF' > /var/www/html/index.php
<!DOCTYPE html>
<html>
<body>
    <center>
    <?php
    # Get the instance ID from meta-data and store it in the $instance_id variable
    $url = "http://169.254.169.254/latest/meta-data/instance-id";
    $instance_id = file_get_contents($url);
    # Get the instance's availability zone from metadata and store it in the $zone variable
    $url = "http://169.254.169.254/latest/meta-data/placement/availability-zone";
    $zone = file_get_contents($url);
    ?>
    <h2>EC2 Instance ID: <?php echo $instance_id ?></h2>
    <h2>Availability Zone: <?php echo $zone ?></h2>
    </center>
</body>
</html>
EOF