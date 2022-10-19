Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0

--==BOUNDARY==
Content-Type: text/cloud-boothook; charset="us-ascii"

# Set iptables configuration

yum install iptables-services -y

cat <<EOF > /etc/sysconfig/iptables 
*filter
:DOCKER-USER - [0:0]
-A DOCKER-USER -d 169.254.169.254/32 -j DROP
COMMIT
EOF

systemctl enable iptables && systemctl start iptables

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
# Set any ECS agent configuration options
echo "ECS_CLUSTER=ecs-lab-cluster" >> /etc/ecs/ecs.config

--==BOUNDARY==--