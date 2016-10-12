*************
Setup Vagrant
*************

การทดสอบการสร้าง virtual machine ด้วย vagrant
::

    $ mkdir  lab
    $ cd lab
    $ vim vagrantfile

.. literalinclude:: lab_vagrantfile

ใช้คำสั่ง vagrant up
::

    $ vagrant up --provider libvirt
    $ vagrant status
    Current machine states:

    client                    running (libvirt)
    server                    running (libvirt)

การเข้าไปยัง vm  ให้ใช้ vagrant ssh โดยให้เปิด terminal 2 terminal

Terminal1::

    vagrant ssh client

    [vagrant@client ~]$ ssh vagrant@10.20.30.41
    The authenticity of host '10.20.30.41 (10.20.30.41)' can't be established.
    ECDSA key fingerprint is 5a:f0:f3:a2:a8:a9:de:d9:2b:89:4b:5b:f6:f4:9e:51.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '10.20.30.41' (ECDSA) to the list of known hosts.
    Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

Terminal2::

    vagrant ssh server

    [vagrant@server ~]$ sudo su -
    [root@server ~]# vi /etc/ssh/sshd_config +79

    PasswordAuthentication yes

    [root@server ~]# systemctl restart ssh


Terminal1::

    vagrant ssh client

    [vagrant@client ~]$ ssh vagrant@10.20.30.41
    vagrant@10.20.30.41's password:
    Last login: Tue Oct 11 13:38:00 2016 from 10.20.30.40
    [vagrant@server ~]$ hostname
    server.example.com

ตั้งค่า ให้กับ /etc/hosts โดยให้ทำทั้ง 2 เครื่อง
::

  sudo su -

  HOST=$(cat << HOST
  127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
  ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
  10.20.30.40 client.example.com  client
  10.20.30.41 server.example.com  server
  HOST
  )

  echo "$HOST" > /etc/hosts
  cat /etc/hosts

ทำการทดสอบ ping
::

  ping  server -c 4
  ping  client -c 4

สร้าง rsa key บนเครื่อง client แล้วส่งไปที่ เครื่องserver ด้วยคำสั่ง

Terminal1::

    [vagrant@client ~]$ ssh-keygen -t rsa -b 4096 -C "Client"
    Generating public/private rsa key pair.
    Enter file in which to save the key (/home/vagrant/.ssh/id_rsa):
    Enter passphrase (empty for no passphrase):
    Enter same passphrase again:
    Your identification has been saved in /home/vagrant/.ssh/id_rsa.
    Your public key has been saved in /home/vagrant/.ssh/id_rsa.pub.
    The key fingerprint is:
    a8:13:11:42:3a:d3:70:b8:5a:66:a9:09:3b:75:64:b5 Client
    The key's randomart image is:
    +--[ RSA 4096]----+
    |.o+ ...          |
    |.= .o. .         |
    |+..+. E          |
    |oo* .. .         |
    |oO .. . S        |
    |*    o           |
    | .  o            |
    |     .           |
    |                 |
    +-----------------+

ทำการ copy key ไปยังเครื่อง server

Terminal1::

    [vagrant@client ~]$ ssh-copy-id server
    The authenticity of host 'server (10.20.30.41)' can't be established.
    ECDSA key fingerprint is 5a:f0:f3:a2:a8:a9:de:d9:2b:89:4b:5b:f6:f4:9e:51.
    Are you sure you want to continue connecting (yes/no)? yes
    /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
    /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
    vagrant@server's password:

    Number of key(s) added: 1

    Now try logging into the machine, with:   "ssh 'server'"
    and check to make sure that only the key(s) you wanted were added.

ทดสอบ ssh ไปยัง server::

    [vagrant@client ~]$ ssh server
    Last login: Tue Oct 11 14:49:04 2016 from 10.20.30.40
    [vagrant@server ~]$ hostname
    server.example.com

ตั้งค่า network service::

    systemctl start network
    systemctl enable network
    systemctl disable NetworkManager
    systemctl stop NetworkManager

ตั้งค่า Timeserver (Terminal 2 )::

    $ sudo yum install chrony -y
    $ vi  /etc/chrony.conf
    //เปลี่ยนแปลง time server
    server 1.th.pool.ntp.org iburst
    server 0.asia.pool.ntp.org iburst
    server 2.asia.pool.ntp.org iburst

    $ sudo systemctl restart chronyd
    $ chronyc source

    210 Number of sources = 3
    MS Name/IP address         Stratum Poll Reach LastRx Last sample
    ===============================================================================
    ^- ntp02.cpe.rmutt.ac.th         2   6     7     1    -16ms[  -11ms] +/-  225ms
    ^* time1.isu.net.sa              1   6     7     0  +5882us[  +11ms] +/-  140ms
    ^+ 202-65-114-202.jogja.citr     2   6     7     1    -13ms[-7965us] +/-   93ms

ตั้งค่า Timeserver (Terminal 1 )::

    sudo yum install chrony -y
    vi  /etc/chrony.conf
    //เปลี่ยนแปลง time server ให้ชื้ไปยัง server
    server 10.20.30.41 iburst
    allow 10.20.30.0/24

    sudo systemctl restart chronyd
    $ chronyc sources
    210 Number of sources = 1
    MS Name/IP address         Stratum Poll Reach LastRx Last sample
    ===============================================================================
    ^? 10.20.30.41                   3   6     1     1  +6209us[+6209us] +/-   84ms
