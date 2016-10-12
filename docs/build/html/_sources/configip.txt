====================
Configure IP address
====================

NetworkManagement
=================
การควบคุม network configuration แบบ manual คือการแก้ไขโดยตรงไปยัง ไฟล์ ที่อยู่ใน ``/etc/sysconfig/network-scripts/`` หลังจากทำการแก้ไขแล้วก็ให้ทำการ reload  ผ่านทาง NetworkManager ด้วยคำสั่ง ``nmcli con reload``
การใช้งาน NetworkManager สามารถใช้ได้ดังนี้

* ``nmtui`` ใช้งานผ่านทาง text user interface 
* ``nmcli`` ใช้งานผ่านทาง commandline

Basic Command
*************
nmcli & ip command
------------------
รูปแบบคำสั่ง ip::


	ip OBJECT COMMAND
	ip [options] OBJECT COMMAND
	ip OBJECT help

.. image:: images/ip002.png

*. แสดงข้อมูลทุก network interface
::

	ip a
	--หรือ--
	ip addr

.. image:: images/ip002.png

*. แสดงผล ipv4 ipv6
::

	### Only show TCP/IP IPv4  ##
	ip -4 a
	 
	### Only show TCP/IP IPv6  ###
	ip -6 a

*. แสดงผลบาง interface
::

	### Only show eth0 interface ###
	ip a show eth0
	ip a list eth0
	ip a show dev eth0
 
	### Only show running interfaces ###
	ip link ls up

*. กำหนด ip ให้แก่ interface 
::

	### syntax 
	ip a add {ip_addr/mask} dev {interface}

	### ตัวอย่าง กำหนด ip 192.168.1.200 ให้แก่ interface eth0
	ip a add 192.168.1.200/255.255.255.0 dev eth0

*. ลบ ip จาก interface
::

	### syntax
	ip a del {ipv6_addr_OR_ipv4_addr} dev {interface}

	### ตัวอย่าง
	ip a del 192.168.1.200/24 dev eth0

*. เปลี่ยน สถานะของ Dev (interface)
::

	### Syntax
	ip link set dev {DEVICE} {up|down}
	### ตัวอย่าง

	ip link set dev eth1 up
	ip link set dev eth1 down

*. เปลี่ยนค่า MTU
::

	### syntax
	ip link set mtu {NUMBER} dev {DEVICE}

	### ตัวอย่าง
	ip link set mtu 9000 dev eth0
	ip a list eth0

.. image:: images/ip004.png

#. แสดงค่า neighbour/apr cache
::

	ip n show
	ip neigh show

	(result)
	192.168.89.123 dev wlp2s0 lladdr 08:5b:0e:a0:d1:0e STALE
	192.168.50.95 dev enp3s0 lladdr 78:48:59:16:41:21 REACHABLE
	192.168.89.254 dev wlp2s0 lladdr 00:1a:1e:24:aa:10 STALE

ความหมาย
	* STALE – The neighbour is valid, but is probably already unreachable, so the kernel will try to check it at the first transmission
	* DELAY – A packet has been sent to the stale neighbour and the kernel is waiting for confirmation.
	* REACHABLE – The neighbour is valid and apparently reachable.


#. แสดง routing table
::
    ### syntax
	ip r
	ip r list
	ip r list [options]
	ip route
	(result)
	default via 192.168.50.95 dev enp3s0  proto static  metric 100 
	default via 192.168.89.123 dev wlp2s0  proto static  metric 600 
	192.168.1.0/24 dev br0  proto kernel  scope link  src 192.168.1.69  metric 425 linkdown 
	192.168.50.0/24 dev enp3s0  proto kernel  scope link  src 192.168.50.168  metric 100 
	192.168.89.0/24 dev wlp2s0  proto kernel  scope link  src 192.168.89.94  metric 600 
	192.168.122.0/24 dev virbr0  proto kernel  scope link  src 192.168.122.1 linkdown 

	### แสดง route ระบุ subnet
	ip r list 192.168.50.0/24
	192.168.50.0/24 dev enp3s0  proto kernel  scope link  src 192.168.50.168  metric 100 

ติดตั้ง nmtui::

	# dnf install NetworkManager-tui
	(result)
    Last metadata expiration check: 1:26:00 ago on Sun Jul  3 20:03:42 2016.
	Dependencies resolved.
	==================================================================================================
	 Package                      Arch             Version                    Repository         Size
	==================================================================================================
	Installing:
	 NetworkManager-tui           x86_64           1:1.2.2-2.fc24             updates           196 k

	Transaction Summary
	==================================================================================================
	Install  1 Package

	Total download size: 196 k
	Installed size: 258 k
	Is this ok [y/N]: 
    

	# nmtui

.. image:: images/ip001.png

แสดง network configuration
::

	# ip -V
	ip utility, iproute2-ss160111

	# ip a
	(result)
	1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
		link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
		inet 127.0.0.1/8 scope host lo
		   valid_lft forever preferred_lft forever
		inet6 ::1/128 scope host 
		   valid_lft forever preferred_lft forever
	2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
		link/ether 54:ee:75:8a:86:09 brd ff:ff:ff:ff:ff:ff
		inet 192.168.1.69/24 brd 192.168.1.255 scope global dynamic enp3s0
		   valid_lft 84893sec preferred_lft 84893sec
		inet6 fe80::3964:9f02:60f4:3751/64 scope link 
		   valid_lft forever preferred_lft forever
	3: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
		link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
		inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
		   valid_lft forever preferred_lft forever


	# ip r
	(result)
	default via 192.168.1.1 dev enp3s0  proto static  metric 100 
	192.168.1.0/24 dev enp3s0  proto kernel  scope link  src 192.168.1.69  metric 100 
	192.168.122.0/24 dev virbr0  proto kernel  scope link  src 192.168.122.1 linkdown 

	# nmcli con show
	(result)
	NAME                      UUID                                  TYPE             DEVICE 
	enp3s0                    86ad9274-8e34-3085-bd6b-6b67a1024ff7  802-3-ethernet   enp3s0 
	virbr0                    3ef73c1b-e369-44dc-8914-48883472c5ce  bridge           virbr0 

	# nmcli dev status
	(result)
	DEVICE      TYPE      STATE      CONNECTION 
	virbr0      bridge    connected  virbr0     
	enp3s0      ethernet  connected  enp3s0      
	lo          loopback  unmanaged  --  

	# nmcli con show enp3s0
	(result)
	connection.id:                          enp3s0
	connection.uuid:                        86ad9274-8e34-3085-bd6b-6b67a1024ff7
	connection.interface-name:              --
	connection.type:                        802-3-ethernet
	connection.autoconnect:                 yes
	connection.autoconnect-priority:        -999
	connection.timestamp:                   1467557036
	connection.read-only:                   no
	connection.permissions:                 
	connection.zone:                        --
	connection.master:                      --
	connection.slave-type:                  --
	connection.autoconnect-slaves:          -1 (default)
	connection.secondaries:                 
	connection.gateway-ping-timeout:        0
	connection.metered:                     unknown
	connection.lldp:                        -1 (default)
	802-3-ethernet.port:                    --
	802-3-ethernet.speed:                   0
	802-3-ethernet.duplex:                  --
	802-3-ethernet.auto-negotiate:          yes
	802-3-ethernet.mac-address:             54:EE:75:8A:86:09
	802-3-ethernet.cloned-mac-address:      --
	802-3-ethernet.mac-address-blacklist:   
	802-3-ethernet.mtu:                     auto
	802-3-ethernet.s390-subchannels:        
	802-3-ethernet.s390-nettype:            --
	802-3-ethernet.s390-options:            
	802-3-ethernet.wake-on-lan:             1 (default)
	802-3-ethernet.wake-on-lan-password:    --
	ipv4.method:                            auto
	ipv4.dns:                               
	ipv4.dns-search:                        
	ipv4.dns-options:                       (default)
	ipv4.addresses:                         
	ipv4.gateway:                           --
	ipv4.routes:                            
	ipv4.route-metric:                      -1
	ipv4.ignore-auto-routes:                no
	ipv4.ignore-auto-dns:                   no
	ipv4.dhcp-client-id:                    --
	ipv4.dhcp-timeout:                      0
	ipv4.dhcp-send-hostname:                yes
	ipv4.dhcp-hostname:                     --
	ipv4.dhcp-fqdn:                         --
	ipv4.never-default:                     no
	ipv4.may-fail:                          yes
	ipv4.dad-timeout:                       -1 (default)
	ipv6.method:                            auto
	ipv6.dns:                               
	ipv6.dns-search:                        
	ipv6.dns-options:                       (default)
	ipv6.addresses:                         
	ipv6.gateway:                           --
	ipv6.routes:                            
	ipv6.route-metric:                      -1
	ipv6.ignore-auto-routes:                no
	ipv6.ignore-auto-dns:                   no
	ipv6.never-default:                     no
	ipv6.may-fail:                          yes
	ipv6.ip6-privacy:                       -1 (unknown)
	ipv6.addr-gen-mode:                     stable-privacy
	ipv6.dhcp-send-hostname:                yes
	ipv6.dhcp-hostname:                     --
	GENERAL.NAME:                           enp3s0
	GENERAL.UUID:                           86ad9274-8e34-3085-bd6b-6b67a1024ff7
	GENERAL.DEVICES:                        enp3s0
	GENERAL.STATE:                          activated
	GENERAL.DEFAULT:                        yes
	GENERAL.DEFAULT6:                       no
	GENERAL.VPN:                            no
	GENERAL.ZONE:                           --
	GENERAL.DBUS-PATH:                      /org/freedesktop/NetworkManager/ActiveConnection/5
	GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/Settings/1
	GENERAL.SPEC-OBJECT:                    /
	GENERAL.MASTER-PATH:                    --
	IP4.ADDRESS[1]:                         192.168.1.69/24
	IP4.GATEWAY:                            192.168.1.1
	IP4.DNS[1]:                             192.168.1.1
	IP4.DNS[2]:                             117.121.222.222
	DHCP4.OPTION[1]:                        requested_routers = 1
	DHCP4.OPTION[2]:                        requested_domain_search = 1
	DHCP4.OPTION[3]:                        requested_time_offset = 1
	DHCP4.OPTION[4]:                        requested_domain_name = 1
	DHCP4.OPTION[5]:                        requested_rfc3442_classless_static_routes = 1
	DHCP4.OPTION[6]:                        requested_classless_static_routes = 1
	DHCP4.OPTION[7]:                        requested_wpad = 1
	DHCP4.OPTION[8]:                        requested_broadcast_address = 1
	DHCP4.OPTION[9]:                        next_server = 0.0.0.0
	DHCP4.OPTION[10]:                       broadcast_address = 192.168.1.255
	DHCP4.OPTION[11]:                       requested_interface_mtu = 1
	DHCP4.OPTION[12]:                       requested_subnet_mask = 1
	DHCP4.OPTION[13]:                       expiry = 1467641649
	DHCP4.OPTION[14]:                       dhcp_lease_time = 86400
	DHCP4.OPTION[15]:                       ip_address = 192.168.1.69
	DHCP4.OPTION[16]:                       requested_static_routes = 1
	DHCP4.OPTION[17]:                       dhcp_message_type = 5
	DHCP4.OPTION[18]:                       requested_domain_name_servers = 1
	DHCP4.OPTION[19]:                       requested_nis_servers = 1
	DHCP4.OPTION[20]:                       requested_ntp_servers = 1
	DHCP4.OPTION[21]:                       subnet_mask = 255.255.255.0
	DHCP4.OPTION[22]:                       routers = 192.168.1.1
	DHCP4.OPTION[23]:                       domain_name_servers = 192.168.1.1 117.121.222.222
	DHCP4.OPTION[24]:                       requested_ms_classless_static_routes = 1
	DHCP4.OPTION[25]:                       requested_nis_domain = 1
	DHCP4.OPTION[26]:                       network_number = 192.168.1.0
	DHCP4.OPTION[27]:                       requested_host_name = 1
	DHCP4.OPTION[28]:                       dhcp_server_identifier = 192.168.1.1
	IP6.ADDRESS[1]:                         fe80::3964:9f02:60f4:3751/64
	IP6.GATEWAY:                            

set static ip
-------------
เนื่องจาก enp3s0 เป็นการกำหนดแบบ ipv4.method auto หมายถึง เป็นแบบ dhcp เปลี่ยนให้เป็น static ip ด้วยวิธีการดังนี้
* การกำหนดค่า ip เช่น '192.168.1.69/24 ' ให้แก่ ตัวแปร ipv4.address 
* เปลี่ยน gateway ให้เป็น 192.168.1.1 
* และเปลี่ยนค่า ipv4.method ให้เป็น manual
::
	nmcli con mod enp3s0 ipv4.addresses "192.168.1.69/24"
	nmcli con mod enp3s0 ipv4.gateway "192.168.1.1"
	nmcli con mod enp3s0 ipv4.method manual

เปลี่ยนค่าทันที
::
	# cat /etc/sysconfig/network-scripts/ifcfg-enp3s0 
	HWADDR=54:EE:75:8A:86:09
	TYPE=Ethernet
	BOOTPROTO=none
	DEFROUTE=yes
	IPV4_FAILURE_FATAL=no
	IPV6INIT=yes
	IPV6_AUTOCONF=yes
	IPV6_DEFROUTE=yes
	IPV6_FAILURE_FATAL=no
	IPV6_ADDR_GEN_MODE=stable-privacy
	NAME=enp3s0
	UUID=86ad9274-8e34-3085-bd6b-6b67a1024ff7
	ONBOOT=yes
	AUTOCONNECT_PRIORITY=-999
	IPADDR=192.168.1.69
	PREFIX=24
	GATEWAY=192.168.1.1
	IPV6_PEERDNS=yes
	IPV6_PEERROUTES=yes

# nmcli con del enp3s0
--หรือ
# nmcli con del 86ad9274-8e34-3085-bd6b-6b67a1024ff7



