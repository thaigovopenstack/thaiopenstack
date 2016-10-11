===================
SetupVM for Testing
===================

Clone VM
========
สิ่งต้องเตรียมให้พร้อม

* เครื่อง host จะต้องติดตั้ง package kvm,libvirt,virt-manager ให้พร้อม `Install Virtualization System`_
* ให้ Download iso image ให้พร้อม 

Geting clone vm with virt-tools
*******************************

Install
-------

สร้าง Centos 7 vm ด้วย virt manager มีขึ้นตอนดังนี้

#.  เปิด virt-manager เลือกเมนู File > New Virtual Machine
#. จะแสดง กล่องข้อความ ขึ้นมาดังรูป ให้เลือก ตัวเลือก แรก ``Local install media (ISO image or CDROM)`` เนื่องจากจะทำการติดตั้งจากไฟล์ชนิด iso ที่ต้องเตรียมไว้ 

.. image::  images/vm001.png

3. ต่อมาให้เลือก ปุ่มที่เขียนไว้ว่า ``Forward`` โดยจะอยู่ในแถวด้านล่าง
#. หลังจากนั้นให้เลือกตัวเลือก ``Use ISO image``และเลือกfile iso ที่ได้ Download ไว้ก่อนล่วงหน้า

.. image::  images/vm002.png

4. เลือก ขนาดของ CPU ที่ต้องการ  โดยจะหน่วยเป็น MiB ดังนั้นตัวอย่างถ้าเราต้องการ vm ที่มี ขนาดหน่วยความจำ 2G ให้กำหนดเป็น 2048 และเลือกขนาด CPU เป็น 2 เมื่อเลือกเสร็จแล้วก็กด ``Forward``เพืิ่มดำเนินการต่อ

.. image::  images/vm003.png

5. เลือกขนาดของ disk ที่ต้องการ ในที่นี้เลือกขนาด 40 มีหน่วยเป็น GiB ในบางกรณีที่ไม่ต้องการใช้เนื้อที่มากก็สามารถเลือกขนาดการทดสอบได้เป็น 20 GiB หลังจากเลือกขนาดที่ต้องการแล้ว ก็กด ``Forward``เพืิ่มดำเนินการต่อ

.. image::  images/vm004.png

6. ตั้งชื้อของ Vm ที่ต้องการเช่น base-centos7 โดยตั้งชี้อเป็นอะไรก็ได้ตามที่ต้องการ แนะนำให้ตั้งชื่อ ``base-*`` เพื่อให้สังเกตุเท่านั้น

.. image::  images/vm005.png

7. เข้าสู่ขั้นตอนการตั้ดตั้ง โดยจะต้องเลือก เมนู ``Install CentOS `` สามารถสัั่งเกตุว่าจะต้องมีอักษรสีขาวแสดงว่าได้ทำการเลือกแล้ว โดยสามารถใช้ cursor up/down เพื่อที่การเลื่อน

.. image::  images/vm006.png

8. เลือกภาษาในระหว่างการติดตั้ง โดยจะเลือก ``English``  สามารถเลือกเมนูเสริมให้สะดวกในการติดตั้ง   View > Resize to VM เพื่อให้มีขนาดยืดหยุ่นตาม

.. image::  images/vm007.png

9. เข้าสู่การหน้าหลักสำหรับการติดตั้ง 

.. image::  images/vm008.png

10. เริ่มโดยการกำหนด timezone โดยใช้ mouse คลิกไปที่แผนที่บริเวณประเทศไทย และแสดงผลในกล่องข้อความด้านบน Asia | Bangkok หลังจากนัั้นให้กด ``Done`` เพื่อกลับไปยัง เมนู หลัก

.. image::  images/vm009.png

11. กดเมนู SOFTWARE SELECTION เลือกติดตั้ง แบบ ``Server with GUI`` กด Done

.. image::  images/vm011.png

12. กดเมนู INSTALLATION DESTINATION

.. image::  images/vm012.png

13. กดเลือก Click here to create the automatically  เพื่อสร้าง partition

.. image::  images/vm013.png

14. ลักษณะ  patition จะแบ่งเป็น 3 ส่วน ประกอบด้วย /boot มีลักษณะเป็น  standard partion มีขนาด 500 MiB ทำหน้าสำหรับเก็บ kernel สำหรับการ boot ส่วนต่อมา  root filesystem แทนด้วย ``/``  โดยมีลักษณะที่เรียกว่า single root file system เพราะไม่มีการแบ่ง  file system ไปอยู่ที่ partition อื่นเนื่องจากเป็นการติดตั้งแบบ Server  

.. image::  images/vm014.png

15. หลังจาก กด Done แล้วให้ กด ``Accept Changes`` เพื่อยืนยัน

.. image::  images/vm015.png

16. อีกส่วนที่ต้องการตั้งค่าคือ NETWORK & HOST NAME เพืื่อต้องการให้ network เริ่มต้นการทำงาน ร้องขอ ไป ยัง DHCP Server  ทุกครั้ง (onboot=YES)

.. image::  images/vm016.png

17. ให้เปลี่ยนสถานะของเป็น on จะได้แสดง ค่า ของ ip address โดย ip ที่ได้จะมี subnet 192.168.122.118 มี gateway 192.168.122.1 และ DNS 192.168.122.1 โดยค่าที่ได้นั้นจะได้ รับมาจาก DHCP Server และจะมีค่า ของ Mac address 52:54:00:FE:A1:F2

.. image::  images/vm017.png

18. หลังจาก กดเลือก configure นั้นเพื่อเป็นการตั้งค่าให้แก่ การ์ด eth0 โดยเลือก ที่ tab แรก มีชื่อว่า general และเลือก ``Automatically connect to this network when it is avialable``

.. image::  images/vm019.png

หากต้องการที่จะ กำหนด ip แบบ manual โดยค่า Default จะกำหนดเป็น DHCP

.. image::  images/vm020.png

เมื่อเรียบร้อยให้กด Begin Installation

19. กำหนด password ให้แก่ user root พร้อมกับการสร้าง user อีกคนเพื่อใช้งาน ในตัวอย่างนี้ user คนที่สองมีชื่อ ว่า admin โดยสามารถตั้งชื่อเป็น  อะไรก็ได้ ตามที่ต้องการ

.. image::  images/vm022.png

กำหนด root password

.. image::  images/vm023.png

กำหนด admin user 

.. image::  images/vm024.png

รอจนเสร็จสิ้นกระบวนการ แล้วกด  reboot

.. image::  images/vm027.png

.. image::  images/vm028.png

.. image::  images/vm029.png

Clone process
-------------
ขี้นตอนการ clone โดยการทำงานบน KVM host หรือ Management node (โหนดที่ติดตั้ง kvm ไม่ใช่สั่งใน vm)::

	[root@localhost networks]# virsh list
	 Id    Name                           State
	----------------------------------------------------
	 5     base-centos7                   running


	[root@localhost networks]# virsh suspend  base-centos7
	Domain base-centos7 suspended

	[root@localhost networks]# virsh list
	 Id    Name                           State
	----------------------------------------------------
	 5     base-centos7                   paused

	[root@localhost networks]# virt-clone --original base-centos7 --name clone-centos7 --file /var/lib/libvirt/images/clone-centos7.qcow2 
	WARNING  Setting the graphics device port to autoport, in order to avoid conflicting.
	Allocating 'clone-centos7.qcow2'                                                                                                        |  40 GB  00:00:05     

	Clone 'clone-centos7' created successfully.


===========  ============================================  ==================
Option       value                                         Descrition
--original   base-centos7                                  base vm name
--name       clone-centos7                                 clone vm name
--file       /var/lib/libvirt/images/clone-centos7.qcow2   clone image name
===========  ============================================  ==================

ถึงแม้ว่าจะclone สำเร็จ แต่มีการ warning ว่า มี conflicting เนื่องจาก clone นั้นจะทำให้ mac address ของ network card ซ้ำกันดังนั้นต้อง ล้าง 
::

	[root@localhost networks]# virsh list --all
	 Id    Name                           State
	----------------------------------------------------
	 5     base-centos7                   paused
	 -     clone-centos7                  shut off

	[root@localhost networks]# virt-sysprep -d clone-centos7
	[   0.0] Examining the guest ...
	[  21.2] Performing "abrt-data" ...
	[  21.2] Performing "bash-history" ...
	[  21.2] Performing "blkid-tab" ...
	[  21.2] Performing "crash-data" ...
	[  21.2] Performing "cron-spool" ...
	[  21.2] Performing "dhcp-client-state" ...
	[  21.2] Performing "dhcp-server-state" ...
	[  21.2] Performing "dovecot-data" ...
	[  21.2] Performing "logfiles" ...
	[  21.3] Performing "machine-id" ...
	[  21.3] Performing "mail-spool" ...
	[  21.3] Performing "net-hostname" ...
	[  21.3] Performing "net-hwaddr" ...
	[  21.3] Performing "pacct-log" ...
	[  21.3] Performing "package-manager-cache" ...
	[  21.3] Performing "pam-data" ...
	[  21.3] Performing "puppet-data-log" ...
	[  21.3] Performing "rh-subscription-manager" ...
	[  21.3] Performing "rhn-systemid" ...
	[  21.3] Performing "rpm-db" ...
	[  21.3] Performing "samba-db-log" ...
	[  21.3] Performing "script" ...
	[  21.3] Performing "smolt-uuid" ...
	[  21.3] Performing "ssh-hostkeys" ...
	[  21.3] Performing "ssh-userdir" ...
	[  21.3] Performing "sssd-db-log" ...
	[  21.3] Performing "tmp-files" ...
	[  21.3] Performing "udev-persistent-net" ...
	[  21.3] Performing "utmp" ...
	[  21.3] Performing "yum-uuid" ...
	[  21.3] Performing "customize" ...
	[  21.3] Setting a random seed
	[  21.8] Performing "lvm-uuids" ...

set password::

	[root@localhost networks]# virt-sysprep -d clone-centos7  --hostname clone-centos7 --root-password password:123456
	[   0.0] Examining the guest ...
	[   2.9] Performing "abrt-data" ...
	[   2.9] Performing "bash-history" ...
	[   2.9] Performing "blkid-tab" ...
	[   2.9] Performing "crash-data" ...
	[   3.0] Performing "cron-spool" ...
	[   3.0] Performing "dhcp-client-state" ...
	[   3.0] Performing "dhcp-server-state" ...
	[   3.0] Performing "dovecot-data" ...
	[   3.0] Performing "logfiles" ...
	[   3.0] Performing "machine-id" ...
	[   3.0] Performing "mail-spool" ...
	[   3.0] Performing "net-hostname" ...
	[   3.0] Performing "net-hwaddr" ...
	[   3.0] Performing "pacct-log" ...
	[   3.0] Performing "package-manager-cache" ...
	[   3.0] Performing "pam-data" ...
	[   3.0] Performing "puppet-data-log" ...
	[   3.0] Performing "rh-subscription-manager" ...
	[   3.0] Performing "rhn-systemid" ...
	[   3.0] Performing "rpm-db" ...
	[   3.0] Performing "samba-db-log" ...
	[   3.0] Performing "script" ...
	[   3.0] Performing "smolt-uuid" ...
	[   3.0] Performing "ssh-hostkeys" ...
	[   3.0] Performing "ssh-userdir" ...
	[   3.0] Performing "sssd-db-log" ...
	[   3.0] Performing "tmp-files" ...
	[   3.0] Performing "udev-persistent-net" ...
	[   3.0] Performing "utmp" ...
	[   3.0] Performing "yum-uuid" ...
	[   3.0] Performing "customize" ...
	[   3.0] Setting a random seed
	[   3.0] Setting the hostname: clone-centos7
	[   3.0] Setting passwords
	[   4.9] Performing "lvm-uuids" ...

Start vm::

	[root@localhost networks]# virsh start  clone-centos7
	Domain clone-centos7 started

	[root@localhost networks]# virsh list
	 Id    Name                           State
	----------------------------------------------------
	 5     base-centos7                   paused
	 8     clone-centos7                  running

	[root@localhost networks]# virt-viewer 8

.. image::  images/vm030.png

ให้ทดสอบ การ login ด้วย root  และ password  ใหม่ โดยให้กด ``not listed`` ที่ เพื่อเปลี่ยนเป็น root user แทน   admin

Install Virtualization System
*****************************
ให้เปิด terminal และติดตั้งด้วยสิทธิ root

.. code-block:: bash
   :linenos:
   
   #verify cpu support virtualization
   egrep '^flags.*(vmx|svm)' /proc/cpuinfo

.. code-block:: bash
   :linenos:

   # fedora 24
   dnf groupinstall "Development Tools" -y 
   dnf groupinfo virtualization
   dnf install @virtualization
   dnf -y install qemu-kvm libvirt virt-install bridge-utils 

   lsmod | grep kvm

   systemctl start libvirtd
   systemctl enable libvirtd
   
   # add user ``admin`` to libvirt group
   useradd -a -G libvirt admin


Network Virtualization
**********************
Libvirt network
---------------
เมื่อทำการติดตั้ง libvirt และ  เริ่มต้นการทำงานแล้วนั้นจะ มีการสร้าง Linux bridge มีชื่อว่า virbr0 โดยทดสอบโดยการใช้คำสั่ง ip a โดยมี ip 192.168.122.1 ทำหน้าเป็น Gateway ให้ Vm เพื่อ  ออกสู่ internet โดยถือว่าเป็น Default bridge และทำหน้าที่เปรียบเสมือน network switch มีการทำงานในลักษณะ NAT  
สามารถตรวจสอบ ไปยัง เมนู  Edit > Connection Detail จะแสดงผลดังรู

.. image::  images/vm025.png

ตรวจสอบด้วยคำสั่ง ip a::

	ip a

	4: virbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
		link/ether 52:54:00:c1:9f:ed brd ff:ff:ff:ff:ff:ff
		inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
		   valid_lft forever preferred_lft forever
	5: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master virbr0 state DOWN group default qlen 1000
		link/ether 52:54:00:c1:9f:ed brd ff:ff:ff:ff:ff:ff

	8: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master virbr0 state UNKNOWN group default qlen 1000
    link/ether fe:54:00:fe:a1:f2 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::fc54:ff:fefe:a1f2/64 scope link 
       valid_lft forever preferred_lft forever

เมื่อ มีการสร้าง VM ขึ้นมา VM ที่สร้างขึ้นจะกูกสร้างมาเกาะบน Bridge ดังกล่าวนี้ โดย  KVM จะสร้าง Port (vnet0) ไว้รองรับ การเชื่อมต่อ จาก vif (virtual interface - eth0) จาก vm

.. image::  images/vm026.png


Network XML
-----------
การกำหนดรายละเอียด ของ config จะอยู่ใน format xml::

	cd /etc/libvirt/qemu/networks

	cat default.xml

	<network>
	  <name>default</name>
	  <uuid>88ec8022-2026-461b-bf66-7daaf33c8fc5</uuid>
	  <forward mode='nat'/>
	  <bridge name='virbr0' stp='on' delay='0'/>
	  <mac address='52:54:00:c1:9f:ed'/>
	  <ip address='192.168.122.1' netmask='255.255.255.0'>
		<dhcp>
		  <range start='192.168.122.2' end='192.168.122.254'/>
		</dhcp>
	  </ip>
	</network>


.. note:: การต้องเปลี่ยน ip default สามารถทำได้ โดยการแก้ไข file xml นี้




