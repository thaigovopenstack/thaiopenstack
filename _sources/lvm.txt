===================
Linux LVM partition
===================

Volumegroups
============
Volume groups are nothing but a pool of storage that consists of one or more physical volumes. Once you create the physical volume, you can create the volume group (VG) from these physical volumes (PV).

pvcreate,vgcreate,lvcreate
**************************
:: 
	
	vagrant ssh server1
    sudo su -
    fdisk -l

         // แสดง disk ทีี่เชื่อมกับ server1
	Disk /dev/vdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
	Units = sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes


	Disk /dev/vdc: 21.5 GB, 21474836480 bytes, 41943040 sectors
	Units = sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes


	Disk /dev/vdd: 21.5 GB, 21474836480 bytes, 41943040 sectors
	Units = sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes

    //create phisical volume
    # pvcreate /dev/vdb 
    Physical volume "/dev/vdb" successfully created

    # pvcreate /dev/vdc
    Physical volume "/dev/vdc" successfully created

    # pvcreate /dev/vdd
    Physical volume "/dev/vdd" successfully created


    # vgcreate myvol  /dev/vdb /dev/vdc /dev/vdd
    Volume group "myvol" successfully created

ตรวจสอบด้วยคำสั่ง vgdisplay
::

	  # vgdisplay
     
	  --- Volume group ---
	  VG Name               myvol
	  System ID             
	  Format                lvm2
	  Metadata Areas        3
	  Metadata Sequence No  1
	  VG Access             read/write
	  VG Status             resizable
	  MAX LV                0
	  Cur LV                0
	  Open LV               0
	  Max PV                0
	  Cur PV                3
	  Act PV                3
	  VG Size               59.99 GiB
	  PE Size               4.00 MiB
	  Total PE              15357
	  Alloc PE / Size       0 / 0   
	  Free  PE / Size       15357 / 59.99 GiB
	  VG UUID               5UZdx5-6m3S-Bh7O-yMWk-A3gS-dJey-N8Ndd1

การใช้งาน volumegroup ได้โดยการแบ่งพื้นที่การใช้งาน ด้วยคำสั่ง lvcreate
::

	# lvcreate -l 5 -n data1 myvol
  	Logical volume "data1" created.

    # lvdisplay
 
  	--- Logical volume ---
  	LV Path                /dev/myvol/data1
  	LV Name                data1
  	VG Name                myvol
  	LV UUID                cVlf5O-SHa5-hB6Y-pSGK-cXaG-9Yok-bMGIxn
  	LV Write Access        read/write
  	LV Creation host, time server1, 2016-07-05 02:37:21 -0400
  	LV Status              available
  	# open                 0
  	LV Size                20.00 MiB
  	Current LE             5
  	Segments               1
  	Allocation             inherit
  	Read ahead sectors     auto
  	- currently set to     8192
  	Block device           253:2

Format สร้าง file system และ  สร้าง mount point สำหรับการใช้้งาน
::

	# mkfs.ext4 /dev/myvol/data1
    # mkdir /data1
    # mount /dev/myvol/data1  /data1
    # cd /data1
    # touch text.txt



