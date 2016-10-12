************************
Openstack with Packstack
************************

packstack
=========

vagrant
*******
สร้าง directory ชื่อ openstack และภายในมี Vagrantfile ดังนี้
::

	# -*- mode: ruby -*-
	# vi: set ft=ruby :

	$script = <<SCRIPT
	echo "run provisioning..."
	echo 'root:password' | sudo chpasswd
	sudo sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
	yum install -y epel-release
	yum install -y centos-release-openstack-mitaka
	yum update -y
	yum install -y openstack-packstack
	SCRIPT

	Vagrant.configure("2") do |config|
	  config.vm.box = "centos/7"
	  config.vm.define :controller do |node|
		    node.vm.network :private_network, :ip => "10.0.0.10"
		    node.vm.network :private_network, :ip => "20.0.0.10"
		    node.vm.provider :libvirt do |domain|
		      domain.uri = 'qemu+unix:///system'
		      domain.driver = 'kvm'
		      domain.host = "server1.example.com"
		      domain.memory = 8192
		      domain.cpus = 4
		      domain.nested = true
		      domain.volume_cache = 'none'
		      domain.storage :file, :size => '20G'
		    end
            node.vm.provision "shell", inline: $script
	  end
	  config.vm.define :compute do |node|
		    node.vm.network :private_network, :ip => "10.0.0.11"
		    node.vm.network :private_network, :ip => "20.0.0.11"
		    node.vm.provider :libvirt do |domain|
		      domain.uri = 'qemu+unix:///system'
		      domain.driver = 'kvm'
		      domain.host = "server2.example.com"
		      domain.memory = 4096
		      domain.cpus = 2
		      domain.nested = true
		      domain.volume_cache = 'none'
		    end
            node.vm.provision "shell", inline: $script
	  end
	end

เข้าไปยัง controller
::

	vagrant ssh controller
    sudo su -
    //set selinux to disable
    getenforce
    sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
    --or--
    vi /etc/selinux/config

    setenforce 0

Disk prepare for cinder
-----------------------
::

    fdisk -l
    pvcreate /dev/vdb
    vgcreate cinder-volumes /dev/vdb
    packstack --gen-answer-file  answerfile001.txt

    sed -i.orig s/192.168.121.158/10.0.0.10/g  answerfile001.txt
    sed -i s/CONFIG_HEAT_INSTALL=n/CONFIG_HEAT_INSTALL=y/g answerfile001.txt

	--ตัวอย่าง--
    grep -n ADMIN_PW  answerfile001.txt
    vim  answerfile001.txt +(line no)

    CONFIG_KEYSTONE_ADMIN_PW=passwd
    CONFIG_LBAAS_INSTALL=y
    CONFIG_NEUTRON_METERING_AGENT_INSTALL=y
    CONFIG_NEUTRON_FWAAS=y

    CONFIG_NEUTRON_ML2_TYPE_DRIVERS=vlan
    CONFIG_NEUTRON_ML2_TENANT_NETWORK_TYPES=vlan
    CONFIG_NEUTRON_ML2_VLAN_RANGES=physnet1:1:1000

    CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS=physnet1:br-eth2
    CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-eth2:eth2

    CONFIG_HEAT_CFN_INSTALL=y
    CONFIG_HORIZON_SSL=y
    CONFIG_PROVISION_DEMO=n

Download complete file :download:`answerfile001.txt <./answerfile001.txt>`.

Run
---
::

    packstack --answer-file answerfile001.txt


.. image:: images/openstack-two-machine-two-nic.png


ผลการ Run

.. image:: images/openstack001.png


Network Config
--------------
backup::

	cp /etc/sysconfig/network-scripts/ifcfg-eth1  /root
	cp /etc/sysconfig/network-scripts/ifcfg-eth1  /etc/sysconfig/network-scripts/ifcfg-br-ex
	cd /etc/sysconfig/network-scripts/

edit::

    vi ifcfg-eth1

	ONBOOT=yes
	DEVICE=eth1
	HWADDR=52:54:00:95:c4:b4
	TYPE=OVSPort
	DEVICETYPE=ovs
	OVS_BRIDGE=br-ex

	vi ifcfg-br-ex

	DEVICE=br-ex
	BOOTPROTO=static
	ONBOOT=yes
	TYPE=OVSBridge
	DEVICETYPE=ovs
	USERCTL=yes
	PEERDNS=yes
	IPV6INIT=no
	IPADDR=10.0.0.10
	NETMASK=255.255.255.0
	GATEWAY=192.168.121.1
	DNS1=8.8.8.8

restart::

	systemctl restart network
	ovs-vsctl show
	(show result  br-ex <--> eth1
	4b34f849-95d8-4651-bbae-40e05d088012
		Bridge br-ex
		    Port "eth1"
		        Interface "eth1"
		    Port br-ex
		        Interface br-ex
		            type: internal


	ip a s eth1
	(eth1 no ip)
	3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master ovs-system state UP qlen 1000
		link/ether 52:54:00:95:c4:b4 brd ff:ff:ff:ff:ff:ff
		inet6 fe80::5054:ff:fe95:c4b4/64 scope link
		   valid_lft forever preferred_lft forever

	ip a s br-ex
	(br-ex have ip)
	12: br-ex: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
		link/ether ce:d5:be:2d:03:40 brd ff:ff:ff:ff:ff:ff
		inet 10.0.0.10/24 brd 10.0.0.255 scope global br-ex
		   valid_lft forever preferred_lft forever
		inet6 fe80::ccd5:beff:fe2d:340/64 scope link
		   valid_lft forever preferred_lft forever

sethostname::

	hostnamectl set-hostname controller.example.com



upload image
------------
(packstack จะสร้าง ไฟล์ keystonerc_admin ใช้สำหรับการ login ทาง commandline)
::

	source keystonerc_admin
    curl http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img | glance \
         image-create --name='cirros image' --visibility=public --container-format=bare --disk-format=qcow2

	+------------------+--------------------------------------+
	| Property         | Value                                |
	+------------------+--------------------------------------+
	| checksum         | ee1eca47dc88f4879d8a229cc70a07c6     |
	| container_format | bare                                 |
	| created_at       | 2016-07-06T06:30:13Z                 |
	| disk_format      | qcow2                                |
	| id               | 52835f4d-90fc-4dfd-85bd-d56a4c886ed7 |
	| min_disk         | 0                                    |
	| min_ram          | 0                                    |
	| name             | cirros image                         |
	| owner            | 4b2f4b8359614a2d930802d428cef551     |
	| protected        | False                                |
	| size             | 13287936                             |
	| status           | active                               |
	| tags             | []                                   |
	| updated_at       | 2016-07-06T06:30:42Z                 |
	| virtual_size     | None                                 |
	| visibility       | public                               |
	+------------------+--------------------------------------+


centos7 image::

	curl http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1606.qcow2 | glance image-create --name='centos7 image' --visibility=public --container-format=bare --disk-format=qcow2
