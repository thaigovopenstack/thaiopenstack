===========================
Network Virtualization Device
===========================

Network Bridge
==============

Getting Setup
*************

Introduction
------------
เราสามารถสร้าง network bridge เพื่อทำหน้าที่เป็น virtual switch ใน linux เพื่อให้รองรับการสร้าง vm guest โดย   vm จะเชื่อมต่ออยู่กับ Network Adapter ที่สร้างที่อยู่บน bridge เดียวกันจะสามารถสื่อสารระหว่างกันได้  เหมือนกับการต่ออยู่กับ physical switch. 
ก่อนหน้านี้เราใช้คำสั่ง brctl จาก package ชื่อ bridge-utils ในการสร้าง bridge และทำการเชื่อม bridgeกับ interface ปัจจุบัน สามารถใช้คำสั่ง ip ที่อยู่ใน package ชื่อ iproute3

IP Command
----------
คำสั่ง ip เป็นคำสั่งที่อยู่ใน package  iproute3 ส่วนคำสั่ง ifconfig จะอยู่ใน package nettools

.. image:: images/Linux-Nettools-vs-Iproute2.png

Syntax
::

	ip OBJECT COMMAND
	ip [options] OBJECT COMMAND
	ip OBJECT help

Object สามารถ แทนค่าได้ตามตารางด้านล่าง ทั้งแบบเต็มหรือแบบย่อ

.. image:: images/ipobject.png

::

    cd ~
    mkdir bridge
    cd bridge
    vagrant init centos/7
    vagrant up
    vagrant ssh
    sudo su -
::

	su -	
    ip addr 
    ip addr show eth0
    ip route show
    traceroute google.com
	
	//list interface
	ip link
	
	#เพิ่ม ip ให้ interface
	# syntax: ip a add {ip_addr/mask} dev {interface}
	ip a add 192.168.1.200/24 dev eth0
	ip a s eth0

	#เปลี่ยนแปลงค่า MTU
	ip link set mtu 9000 dev eth0
	ip a s eth0
	
	#เปลี่ยน route ให้ไปออกที่ eth2 และมี next ip 192.168.1.100
	ip route add default via 192.168.1.100 dev eth2
	ip route
	#ลบ ip route
	ip route del default via 192.168.1.100 dev eth2
  	
	ip link

	ip link add br0 type bridge
	
	#เพิ่ม physical network interface ไปยัง bridge  ที่สร้างมา
	ip link set eth0 master br0

	#เพิ่มip
	ip addr add 192.168.1.100/24 dev br0
	#ลบip	
	ip addr del 192.168.1.100/24 dev br0


Linux bridge
------------ 
เพื่อเชื่อมเครื่องคอมพิวเตอร์ เข้าหากัน โดยการใช้ Mac Address (Layer 2) แทนที่จะเป็นการเชื่อมกันระหว่าง ip (Layer3) โดยปรกติ linux network จะป้องกันไม่ให้ส่ง traffice จาก interface หนึ่งไปอีก interface หนึ่ง เราอาจ ใช้  ip routing ให้ทำหน้าที่ในการส่งข้อมูล ด้วยการกำหนดค่า ใน sysctrl เป็นการทำ ip forward 

::

	cat /proc/sys/net/ipv4/ip_forward	
	vi /etc/sysctrl.conf
	net.ipv4.ip_forward = 1
	sysctl -p /etc/sysctl.conf
	service network restart
	cat /proc/sys/net/ipv4/ip_forward


Linux kernel ยังสามารถ bridge ระหว่าง interface เพื่อส่งผ่าน ethernet frame การสร้าง linux bridge ได้หลายหลายวิธี  โดยมี kernel module
::

	lsmod | grep bridge
	bridge                126976  1 ebtable_broute
	stp                    16384  2 garp,bridge
	llc                    16384  3 stp,garp,bridge


* สร้างด้วย iproute2 คำสั่ง ip
* สร้างด้วย bridge-utils คำสั่ง brctl

iproute2
--------
::

	#bridge ชือ br0
	ip link add br0 type bridge
	ip link
	ip link set dev br0 up

	#เพิ่ม interface (eth0) ไปยัง  bridge ต้องอยู่สถานะ up
	ip addr flush eth0
	ip link set eth0 up
	ip link set eth0 master br0
	#ดูสถานะ
	bridge link
	#ถอด  eth0 จาก br0
	ip link set eth0 nomaster
	#ลบ bridge
	ip link delete br0 type bridge

bridge-utils
------------
::

	#bridge ชือ br0
	brctl addbr br0
	brctl show
	ip link set dev br0 up
	ip addr flush eth0
	brctl addif br0 eth0
	brctl show
	brctl showmacs br0
	#mac ของ bridge คือ mac ของ eth0
	#กำหนด ip
	ip addr add 10.0.0.10/24 dev br0
	ip addr show br0
	brctl showmacs br0

	#ลบbridge ต้อง down ก่อน
	ip link set dev br0 down
	brctl delbr br0

ที่ทำมาทั้งหมด จะหายไปเมื่อมีการ reboot เครื่อง เนื่องจากเป็นเพียง  session เท่านั้น เพื่อต้องการให้การเปลี่ยนแปลง สามารถเป็นแบบ ถาวร จะต้องทำการสร้าง  config file ให้แก่ br0 ที่  ``/etc/sysconfig/network-scripts/ifcfg-br0`` และทำการแก้ไข  ``/etc/sysconfig/network-scripts/ifcfg-eth0`` 

/etc/sysconfig/network-scripts/ifcfg-br0::

	DEVICE=br0
	TYPE=Bridge
	IPADDR=10.0.0.10
	PREFIX=24
	ONBOOT=yes

/etc/sysconfig/network-scripts/ifcfg-eth0::

	DEVICE=eth0
	BRIDGE=br0
	TYPE=Ethernet
	ONBOOT=yes


OVS-project
===========
http://openvswitch.org/

.. image:: images/ovs.png

Test plan
*********
* ให้สร้าง vagrant file เพื่อสร้าง vm
* ภายใน vm สร้าง 2 network name space ด้วยคำสั่ง  ip
* สร้าง openvswitch bridge และเชื่อม network namespace เข้าหากัน
::

    cd ~
    mkdir ovs
    cd ovs
    vagrant init centos/7
    vagrant up
    vagrant ssh
    sudo su -
 
    //list ROOT network namespace
    ifup eth0
    dhclient eth0
    ip link
    ip a 
    ip r

.. image:: images/virtdev001.png

::

    //create new two network namespaces
    ip netns add red
    ip netns add green
    
    //list network name space
    ip netns
    --or--
    ls /var/run/netns

    //delete network namespace !!ไม่ต้องทำ
    ip netns del red
    ip netns del green

.. image:: images/virtdev002.png

::

    //run in network name space
    ip netns exec red ip a
    ip netns exec green ip a

    //up the loopback interfaces (lo) of the namespaces
    ip netns exec red ip link set dev lo up
    ip netns exec green ip link set dev lo up
    
.. image:: images/virtdev003.png

Create Switch (bridge)
::

    yum install wget
    wget ftp://ftp.muug.mb.ca/mirror/centos/7.2.1511/cloud/x86_64/openstack-kilo/common/openvswitch-2.4.0-1.el7.x86_64.rpm
    yum install openvswitch-2.4.0-1.el7.x86_64.rpm
    systemctl start openvswitch
    systemctl enable openvswitch

    lsmod | grep openv
    openvswitch            84543  0 
    libcrc32c              12644  1 openvswitch

    ovs-vsctl add-br ovs1
    ovs-vsctl show
    (result)
    Bridge "ovs1"
        Port "ovs1"
            Interface "ovs1"
                type: internal
    ovs_version: "2.4.0"

    //list in ROOT network namespace    
    ip link
	
.. image:: images/virtdev004.png

.. image:: images/virtdev005.png


การเชื่อมต่อระหว่าง openswitch กับ network name space จะเชื่อมต่อกันด้วย virtual ethernet interface pair
ทำหน้าที่เสมือนท่อระหว่าง openswitch และ network namespace ``eth0-r >--------< veth-r``

.. image:: images/virtdev006.png

::
  
    //create veth pair ไว้ก่อนแต่ยังไม่ได้เชื่อมกัน
    ip link add eth0-r type veth peer name veth-r
    ip link

    // will see both end of pipe
    3: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT 
        link/ether 9e:f0:39:2f:ec:c0 brd ff:ff:ff:ff:ff:ff
    4: ovs1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT 
        link/ether 36:82:a4:26:c1:43 brd ff:ff:ff:ff:ff:ff

    5: veth-r@eth0-r: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
        link/ether ea:41:53:45:9e:ef brd ff:ff:ff:ff:ff:ff
    6: eth0-r@veth-r: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
        link/ether 02:f7:ed:a4:30:62 brd ff:ff:ff:ff:ff:ff

    //add eth0-r to red network namespace    
    ip link set eth0-r netns red
    ip link
    (eth0-r หายไปจาก root network name space)
    3: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT 
        link/ether 9e:f0:39:2f:ec:c0 brd ff:ff:ff:ff:ff:ff
    4: ovs1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT 
        link/ether 36:82:a4:26:c1:43 brd ff:ff:ff:ff:ff:ff
    5: veth-r@if6: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000

    //check in red namespace จะเป็นว่า  eth0-r มาแสดงอยู่ภายใน
    ip netns exec red ip link
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    6: eth0-r@if5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
        link/ether 02:f7:ed:a4:30:62 brd ff:ff:ff:ff:ff:ff link-netnsid 0

    //add อีกข้างหนึ่งของ veth pair เข้ากับ  ovs bridge ในลักษณะการ add port
    ovs-vsctl add-port ovs1 veth-r
    ip link

    ovs-vsctl show
    ee90254e-08b5-4abe-a39a-75ee07ee2ad8
        Bridge "ovs1"
            Port veth-r
                Interface veth-r
            Port "ovs1"
                Interface "ovs1"
                    type: internal
        ovs_version: "2.4.0"

.. image:: images/virtdev007.png

ให้ทำซ้ำสำหรับการสร้าง veth pair เชื่อมต่อระหว่าง green network namespace และ openvswitch อีกครั้งหนึ่ง
::

    ip link add eth0-g type veth peer name veth-g
    ip link set eth0-g netns green
    ovs-vsctl add-port ovs1 veth-g


.. image:: images/virtdev008.png

ขั้นตอนต่อมาคือ turnon interface และ add ip
------------------------------------
Up interface
::

    ip link
    (result)
    5: veth-r@if6: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master ovs-system state DOWN mode DEFAULT qlen 1000
        link/ether ea:41:53:45:9e:ef brd ff:ff:ff:ff:ff:ff link-netnsid 0
    7: veth-g@if8: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master ovs-system state DOWN mode DEFAULT qlen 1000
        link/ether a2:5d:35:e9:71:36 brd ff:ff:ff:ff:ff:ff link-netnsid 1

    ip link set veth-r up
    ip link set veth-g up
    (result)
    5: veth-r@if6: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast master ovs-system state LOWERLAYERDOWN mode DEFAULT qlen 1000
        link/ether ea:41:53:45:9e:ef brd ff:ff:ff:ff:ff:ff link-netnsid 0
    7: veth-g@if8: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast master ovs-system state LOWERLAYERDOWN mode DEFAULT qlen 1000
        link/ether a2:5d:35:e9:71:36 brd ff:ff:ff:ff:ff:ff link-netnsid 1


    ip netns exec red ip link set dev lo up
    ip netns exec red ip link set dev eth0-r up
    ip netns exec green ip link set dev lo up
    ip netns exec green ip link set dev eth0-g up

Add ip
::

    //In read
    ip netns exec red ip a add 10.0.0.1/24 dev eth0-r
    ip netns exec red ip a

    (result)
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
           valid_lft forever preferred_lft forever
    6: eth0-r@if5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
        link/ether 02:f7:ed:a4:30:62 brd ff:ff:ff:ff:ff:ff link-netnsid 0
        inet 10.0.0.1/24 scope global eth0-r
           valid_lft forever preferred_lft forever
        inet6 fe80::f7:edff:fea4:3062/64 scope link 
           valid_lft forever preferred_lft forever

    //check route
    ip netns exec red ip r
    10.0.0.0/24 dev eth0-r  proto kernel  scope link  src 10.0.0.1 

    //In root
    //checkroute ใน root namespace จะเห็นว่า ยังไม่รับทราบ ถึง network 10.0.0.0/24
    ip route
    default via 192.168.121.1 dev eth0  proto static  metric 100 
    192.168.121.0/24 dev eth0  proto kernel  scope link  src 192.168.121.189  metric 100

    //In green
    ip netns exec green ip a add 10.0.0.2/24 dev eth0-g
    ip netns exec green ip a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
           valid_lft forever preferred_lft forever
    8: eth0-g@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
        link/ether 02:9e:59:e8:76:d0 brd ff:ff:ff:ff:ff:ff link-netnsid 0
        inet 10.0.0.2/24 scope global eth0-g
           valid_lft forever preferred_lft forever
        inet6 fe80::9e:59ff:fee8:76d0/64 scope link 
           valid_lft forever preferred_lft forever

.. image:: images/virtdev009.png

Test ping
::

    ip netns exec red bash
    ping -c 4 10.0.0.2
    PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
    64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=0.503 ms
    64 bytes from 10.0.0.2: icmp_seq=2 ttl=64 time=0.061 ms
    64 bytes from 10.0.0.2: icmp_seq=3 ttl=64 time=0.076 ms
    64 bytes from 10.0.0.2: icmp_seq=4 ttl=64 time=0.061 ms

