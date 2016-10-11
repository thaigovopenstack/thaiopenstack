#!/bin/bash -x

sudo setenforce 0

HOST=$(cat << HOST
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.0.0.11  controller.example.com  controller
10.0.0.21  network.example.com  network
10.0.0.31  compute1.example.com compute1
10.0.0.32  compute2.example.com  compute2
10.0.0.41  block1.example.com  block1
10.0.0.51  object1.example.com  object1
HOST
)

sudo echo "$HOST" > /etc/hosts

ISCONNECT=$(cat << TEST 
#!/bin/bash
ping -c 2 controller
ping -c 2 network
ping -c 2 compute1
ping -c 2 compute2
ping -c 2 block1
ping -c 2 object1
TEST
)

sudo echo "$ISCONNECT" > /root/isconnect.sh

#network service
sudo systemctl start network
sudo systemctl enable network
sudo systemctl disable NetworkManager
sudo systemctl stop NetworkManager

#ntp time server
sudo yum install chrony -y
if [ -f /etc/chrony.conf ];then
    if [ $(hostname -s) = "controller" ]; then
        sudo sed -i.orig '3,6d' /etc/chrony.conf
        sudo sed -i '3i server 1.th.pool.ntp.org iburst' /etc/chrony.conf
        sudo sed -i 'server 0.asia.pool.ntp.org iburst' /etc/chrony.conf
        sudo sed -i 'server 2.asia.pool.ntp.org iburst' /etc/chrony.conf
    else
        sudo set -i.orig '3,6d' /etc/chrony.conf
        sudo sed -i.bak '3i server 10.0.0.11 iburst' /etc/chrony.conf
    fi
fi
sudo systemctl restart chronyd

#repo
sudo yum install -y centos-release-openstack-mitaka
sudo yum install -y python-openstackclient
sudo yum install -y openstack-selinux
sudo yum install -y openstack-utils
sudo yum install -y wget
sudo yum upgrade -y



    
