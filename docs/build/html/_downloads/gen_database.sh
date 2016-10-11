#!/bin/sh
#
# Populate openstack database initial configuration to MySQL
#

# Mainly inspired by
# sawangpong muadphet <sawangpong@itbakery.net>
#


file="passwordlist"
if [ ! -f passwordlist ]; then
    echo "Sorry!! , File 'passwordlist' no found,"
    exit 1;
fi

if [ -z "$DB_PASS" ]; then
    echo "Sorry!! Need to run 'source passwordlist' before generate database"
    exit 1
fi

mysql -u root -p$DB_PASS << EOF

#Identity Service
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'controller.example.com' IDENTIFIED BY '$KEYSTONE_DBPASS';

FLUSH PRIVILEGES;

#Image Service
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$GLANCE_DBPASS';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$GLANCE_DBPASS';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'controller.example.com' IDENTIFIED BY '$GLANCE_DBPASS';

FLUSH PRIVILEGES;

#Compute service
CREATE DATABASE nova_api;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'controller.example.com' IDENTIFIED BY '$NOVA_DBPASS';

FLUSH PRIVILEGES;

CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'controller.example.com' IDENTIFIED BY '$NOVA_DBPASS';

FLUSH PRIVILEGES;

#Network Service
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$NEUTRON_DBPASS';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$NEUTRON_DBPASS';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'controller.example.com' IDENTIFIED BY '$NEUTRON_DBPASS';

FLUSH PRIVILEGES;

#Block Storage service
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$CINDER_DBPASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$CINDER_DBPASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'controller.example.com' IDENTIFIED BY '$CINDER_DBPASS';

FLUSH PRIVILEGES;

CREATE DATABASE manila;
GRANT ALL PRIVILEGES ON manila.* TO 'manila'@'%' IDENTIFIED BY '$MANILA_DBPASS';
GRANT ALL PRIVILEGES ON manila.* TO 'manila'@'localhost' IDENTIFIED BY '$MANILA_DBPASS';
GRANT ALL PRIVILEGES ON manila.* TO 'manila'@'controller.example.com' IDENTIFIED BY '$MANILA_DBPASS';

FLUSH PRIVILEGES;

CREATE DATABASE heat;
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY '$HEAT_DBPASS';
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY '$HEAT_DBPASS';
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'controller.example.com' IDENTIFIED BY '$HEAT_DBPASS';

FLUSH PRIVILEGES;

CREATE DATABASE aodh;
GRANT ALL PRIVILEGES ON aodh.* TO 'aodh'@'%' IDENTIFIED BY '$AODH_DBPASS';
GRANT ALL PRIVILEGES ON aodh.* TO 'aodh'@'localhost' IDENTIFIED BY '$AODH_DBPASS';
GRANT ALL PRIVILEGES ON aodh.* TO 'aodh'@'controller.example.com' IDENTIFIED BY '$AODH_DBPASS';

FLUSH PRIVILEGES;

CREATE DATABASE trove;
GRANT ALL PRIVILEGES ON trove.* TO 'trove'@'%' IDENTIFIED BY '$TROVE_DBPASS';
GRANT ALL PRIVILEGES ON trove.* TO 'trove'@'localhost' IDENTIFIED BY '$TROVE_DBPASS';
GRANT ALL PRIVILEGES ON trove.* TO 'trove'@'controller.example.com' IDENTIFIED BY '$TROVE_DBPASS';

FLUSH PRIVILEGES;

EOF

echo "Success create database; Show database"
mysql -uroot -p$DB_PASS -Bse "show databases;"


