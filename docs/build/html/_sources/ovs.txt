==================
OpenVswitch Bridge
==================
เป้าหมาย คือต้องการที่จะใช้งาน virt-manager ให้สามารถใช้งานในรูปแบบของ Bridge mode และใช้งานร่วมกับ openvswitch (virtual switch) เพื่อให้ virtual machine ที่สร้างขึ้นสามารถมี Bride network บน Fedora 20 ได้
อะไรคือ openvswitch
openvswitch คือ virtual switch รองรับการทำงาน openflow protocol เป็นมาตรฐานหลักของ SDN (Software Define networking) โดยที่ Openvswitch จะทำให้ vm ที่สร้างขึ้นสามารถที่ติดต่อกัน ทั้งที่อยู่บน Host เดียวกัน หรือต่าง Host กัน

openvswitch
===========
	* รองรับ VLAN tagging และ 802.1q trunk
	* รองรับ standard spanning tree protocal 802.1D
	* LACP
	* Port mirroring (SPAN/RSPAN)
	* Flow export (sflow, netflow, ipfix)
	* tunneling (GRE, VXLAN, IPSEC)
	* QoS control


Install Openvswitch
*******************
::

	sudo su -
	# dnf install openvswitch python-openvswitch openvswitch-devel
	# systemctl start openvswitch
	# systemctl enable openvswitch
	# lsmod | grep openv

	(result)
	openvswitch           102400  0
	libcrc32c              16384  1 openvswitch
	nf_defrag_ipv6         36864  2 openvswitch,nf_conntrack_ipv6
	nf_nat_ipv6            16384  2 openvswitch,ip6table_nat
	nf_nat_ipv4            16384  2 openvswitch,iptable_nat
	nf_nat                 24576  4 openvswitch,nf_nat_ipv4,nf_nat_ipv6,nf_nat_masquerade_ipv4
	nf_conntrack          106496  8 openvswitch,nf_nat,nf_nat_ipv4,nf_nat_ipv6,xt_conntrack,nf_nat_masquerade_ipv4,nf_conntrack_ipv4,nf_conntrack_ipv6

ให้เด็บค่า inteface name ,ip ,mac ,route ด้วยคำสั่ง
::

	ip a
	ip r

	
create bridge
-------------
::

	# ovs-vsctl add-br ovsbr0
	# ovs-vsctl show
    (result)
	e3aa10d9-ca5d-47e4-8eea-5f754cfae0fe
    	Bridge "ovsbr0"
        Port "ovsbr0"
            Interface "ovsbr0"
                type: internal
    	ovs_version: "2.5.0"


นำ  interface enp3s0 มาเชื่อมกับ ovsbr0
::

	# ovs-vsctl add-port ovsbr0 enp3s0
	# ovs-vsctl show
	(result)
	e3aa10d9-ca5d-47e4-8eea-5f754cfae0fe
		Bridge "ovsbr0"
		    Port "ovsbr0"
		        Interface "ovsbr0"
		            type: internal
		    Port "enp3s0"
		        Interface "enp3s0"
		ovs_version: "2.5.0"

.. image:: images/ovs002.png

หลังจากนั้นให้ แก้ config
::

		cd /etc/sysconfig/network-scripts
		cp ifcfg-enp3s0  /root
		cp ifcfg-enp3s0  ifcfg-ovsbr0

edit network config
::

	# cd /etc/sysconfig/network-scripts
  # vim ifcfg-enp3s0

	DEVICE=enp3s0
  NAME=enp3s0
	HWADDR=54:ee:75:8a:86:09
	ONBOOT=yes
	DEVICETYPE=ovs
	TYPE=OVSPort
	OVS_BRIDGE=ovsbr0

.. note:: ให้แทนค่า

		* enp3s0 ด้วยชื่อของ interface ของตัวเอง
		* HWADDR=54:ee:75:8a:86:09  ด้วย mac ของตัวเอง

::

	# vim ifcfg-ovsbr0

	DEVICE=ovsbr0
	NAME=ovsbr0
	DEVICETYPE=ovs
	TYPE=OVSBridge
	BOOTPROTO=static
	DEFROUTE=yes
	ONBOOT=yes
	IPADDR=192.168.1.100
	PREFIX=24
	GATEWAY=192.168.1.1
	DNS1=8.8.8.8
	DNS2=8.8.4.4
	HOTPLUG=no
	DELAY=0
	IPV6INIT=no

ยกเลิกการทำงาน NetworkManager
::

.. note:: ให้แทนค่า

		* 192.168.1.100 ด้วย ip เดิม ของ enp3s0

	systemctl stop NetworkManager
	systemctl disable NetworkManager

	systemctl start network
	systemctl enable network

	reboot
