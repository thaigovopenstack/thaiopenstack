openssl rand -hex 10
CINDER_DBPASS  7bb03e9f2047e7007a77
CINDER_PASS    dca00bf3e187c80a9009

mysql> CREATE DATABASE cinder;
mysql> GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' \
  IDENTIFIED BY '7bb03e9f2047e7007a77';
mysql> GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' \
  IDENTIFIED BY '7bb03e9f2047e7007a77';


openstack user create --domain default --password-prompt cinder
openstack role add --project service --user cinder admin
 openstack service create --name cinder \
  --description "OpenStack Block Storage" volume

openstack endpoint create --region RegionOne \
  volume public http://storage:8776/v1/%\(tenant_id\)s

   openstack endpoint create --region RegionOne \
  volume internal http://storage:8776/v1/%\(tenant_id\)s

  openstack endpoint create --region RegionOne \
  volume admin http://storage:8776/v1/%\(tenant_id\)s



yum install openstack-cinder
/etc/cinder/cinder.conf

[database]
...
connection = mysql+pymysql://cinder:CINDER_DBPASS@controller/cinder

[DEFAULT]
...
rpc_backend = rabbit

[oslo_messaging_rabbit]
...
rabbit_host = controller
rabbit_userid = openstack
rabbit_password = RABBIT_PASS


[DEFAULT]
...
auth_strategy = keystone

[keystone_authtoken]
...
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = cinder
password = CINDER_PASS


[DEFAULT]
...
my_ip = 10.0.0.11


[oslo_concurrency]
...
lock_path = /var/lib/cinder/tmp


su -s /bin/sh -c "cinder-manage db sync" cinder
