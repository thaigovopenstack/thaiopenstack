================
Install keystone
================

start install
=============

Download vagrant and bootstrap :download:`Vagrant and Bootstrap <./openstack3.tar.gz>`
::

    cd ~
    wget https://thaiopen.github.io/SipaLinuxCourse/_downloads/openstack3.tar.gz
    tar xvf openstack3.tar.gz
    cd openstack3
    bash start.sh
    vagrant ssh controller
    sudo su -
    cd /vagrant
    ls

    bootstrap.sh     gen_pass.sh  isconnect.sh  passwordlist  Vagrantfile
    gen_database.sh  hosts        mysql.sh      start.sh      virsh-manage.sh

    cp hosts  /etc/hosts

    $ bash isconnect.sh
    Success test ping from controller to controller
    Success test ping from controller to network
    Success test ping from controller to compute1
    Success test ping from controller to compute2
    Success test ping from controller to block1
    Success test ping from controller to object1
    Success test ping from controller to object2
    Success test ping from controller to share1
    Success test ping from controller to share2


    // Enable password

    # vi /etc/ssh/sshd_config +79
        PasswordAuthentication yes

    # systemctl restart sshd
    // Gen key id_rsa.pub

    # ssh-keygen -t rsa -b 4096 -C "openstack"
    # ls ~/.ssh/
    id_rsa  id_rsa.pub

    //copy key ไปยัง ทุกโหนด
    # ssh-copy-id compute1
    //test

    # ssh compute
    # ssh-copy-id localhost
    # ssh localhost

Install Process
===============
root password is $DB_PASS. please chech database (optional)
::

	echo $DB_PASS

	mysql -uroot -p$DB_PASS

	Enter password:
	Welcome to the MariaDB monitor.  Commands end with ; or \g.
	Your MariaDB connection id is 7
	Server version: 10.1.12-MariaDB MariaDB Server

	Copyright (c) 2000, 2016, Oracle, MariaDB Corporation Ab and others.

	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

	MariaDB [(none)]> FLUSH PRIVILEGES;
	MariaDB [(none)]> exit

    //show database
    mysql -uroot -p$DB_PASS -e "show databases;"

    //show user
    mysql -uroot -p$DB_PASS -e "SELECT User,host from mysql.user;"


Create Database
***************
::

    source passwordlist
    bash gen_database.sh
    mysql -uroot -p$DB_PASS -e "show databases;"
    mysql -uroot -p$DB_PASS -e "SELECT User,host from mysql.user;"

    //if need to delete all user and database
    //delete database
    mysql -uroot -p$DB_PASS -e "show databases;"
    dbs="keystone glance nova_api nova neutron cinder manila heat aodh trove"
    for d in $dbs; do  mysql -uroot -p$DB_PASS -e "DROP DATABASE $d" ; done
    mysql -uroot -p$DB_PASS -e "show databases;"
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | mysql              |
    | performance_schema |
    +--------------------+

    //show user
    mysql -uroot -p$DB_PASS -e "SELECT User,host from mysql.user;"
    //delete user
    services="keystone glance nova neutron cinder manila heat aodh trove"
    for s in $services; do  mysql -uroot -p$DB_PASS -e "DROP USER  '$s'@'%'" ; done
    for s in $services; do  mysql -uroot -p$DB_PASS -e "DROP USER  '$s'@'localhost'" ; done
    for s in $services; do  mysql -uroot -p$DB_PASS -e "DROP USER  '$s'@'controller.example.com'" ; done


Install package
***************
::

	yum install openstack-keystone httpd mod_wsgi

option1 edit manual
-------------------
/etc/keystone/keystone.conf
::

    [DEFAULT]
    ...
    admin_token = ADMIN_TOKEN


    [database]
    ...
    connection = mysql+pymysql://keystone:KEYSTONE_DBPASS@controller/keystone


    [token]
    ...
    provider = fernet

อย่าลืมแทนท่า ADMIN_TOKEN และ KEYSTONE_DBPASS ใน passwordlist

option2 edit by openstack-config
--------------------------------
::

    keystone="openstack-config --set /etc/keystone/keystone.conf"
    $keystone DEFAULT admin_token  $ADMIN_TOKEN
    $keystone database connection mysql+pymysql://keystone:$KEYSTONE_DBPASS@controller/keystone
    $keystone token provider fernet


Create tables in keystone database
::

    su -s /bin/sh -c "keystone-manage db_sync" keystone

Initialize key
::

    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

Config apache
::

    vi /etc/httpd/conf/httpd.conf
    96 ServerName controller

vi /etc/httpd/conf.d/wsgi-keystone.conf
::

    Listen 5000
    Listen 35357

    <VirtualHost *:5000>
        WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
        WSGIProcessGroup keystone-public
        WSGIScriptAlias / /usr/bin/keystone-wsgi-public
        WSGIApplicationGroup %{GLOBAL}
        WSGIPassAuthorization On
        ErrorLogFormat "%{cu}t %M"
        ErrorLog /var/log/httpd/keystone-error.log
        CustomLog /var/log/httpd/keystone-access.log combined

        <Directory /usr/bin>
            Require all granted
        </Directory>
    </VirtualHost>

    <VirtualHost *:35357>
        WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
        WSGIProcessGroup keystone-admin
        WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
        WSGIApplicationGroup %{GLOBAL}
        WSGIPassAuthorization On
        ErrorLogFormat "%{cu}t %M"
        ErrorLog /var/log/httpd/keystone-error.log
        CustomLog /var/log/httpd/keystone-access.log combined

        <Directory /usr/bin>
            Require all granted
        </Directory>
    </VirtualHost>

::

    systemctl enable httpd.service
    systemctl start httpd.service

set environment variable
::

    export OS_TOKEN=$ADMIN_TOKEN
    export OS_URL=http://controller:35357/v3
    export OS_IDENTITY_API_VERSION=3

Create service Entry
--------------------
create
::

    openstack service create --name keystone --description "OpenStack Identity" identity

    +-------------+----------------------------------+
    | Field       | Value                            |
    +-------------+----------------------------------+
    | description | OpenStack Identity               |
    | enabled     | True                             |
    | id          | fc434971e4e14cfc8a222cd32daf1880 |
    | name        | keystone                         |
    | type        | identity                         |
    +-------------+----------------------------------+

delete
::

    openstack service list
    +----------------------------------+----------+----------+
    | ID                               | Name     | Type     |
    +----------------------------------+----------+----------+
    | fc434971e4e14cfc8a222cd32daf1880 | keystone | identity |
    | fd5dc8b1b81c4bf780e0f3127ef03c61 | keystone | identity |
    +----------------------------------+----------+----------+

    openstack service delete fc434971e4e14cfc8a222cd32daf1880
    openstack service delete fd5dc8b1b81c4bf780e0f3127ef03c61

Loging
::

    cd /var/log/keystone
    ls
    tail -f keystone.log

    cd /var/log/httpd/
    ls

Create Endpoint
::

        openstack endpoint create --region RegionOne identity public http://controller:5000/v3
        openstack endpoint create --region RegionOne identity internal http://controller:5000/v3
        openstack endpoint create --region RegionOne identity admin http://controller:35357/v3
        openstack endpoint list



Domain Project User
::

    openstack domain create --description "Default Domain" default

    openstack project create --domain default --description "Admin Project" admin
    openstack user create --domain default --password-prompt admin
    openstack role create admin
    openstack role add --project admin --user admin admin

    openstack project create --domain default --description "Service Project" service


    openstack project create --domain default --description "Demo Project" demo
    openstack user create --domain default --password-prompt demo
    openstack role create user
    openstack role add --project demo --user demo user
