***************
Openstack Cloud
***************

::

    mkdir lab2
    cd lab2
    vi Vagrantfile


Vagrantfile

.. literalinclude:: lab2_vagrantfile


Terminal1::

    vagrant status
    vagrant ssh controller
    sudo su -
    ssh-keygen -t rsa -b 4096 -C "openstack"
    ssh-copy-id compute
    ssh-copy-id controller

    //Test ssh
    ssh compute
    exit
    ssh controller
    exit

Terminal1::

    //prepare disk for volume group
    sudo su -
    fdisk -l

    fdisk /dev/vdb
    n
    p
    1
    enter
    enter
    w

    partprobe

    pvcreate /dev/vdb1
    vgcreate cinder-volumes /dev/vdb1

เครื่อง controller

Terminal1::

    //run packstck
    //packstack --install-hosts=CONTROLLER_ADDRESS,COMPUTE_ADDRESSES

    sudo su -
    packstack --install-hosts=10.10.10.10,10.10.10.11 \
    --nagios-install=n \
    --provision-demo=n \
    --nagios-install=n \
    --os-neutron-ovs-bridge-mappings=extnet:br-ex,physnet1:br-eth2 \
    --os-neutron-ovs-bridge-interfaces=br-ex:eth0,br-eth2:eth2 \
    --os-neutron-ml2-type-drivers=vxlan,flat,local,vlan \
    --os-neutron-ml2-vlan-ranges=physnet1:1000:2000 \
    --os-heat-install=y --os-heat-cfn-install=y \
    --os-sahara-install=y --os-trove-install=y \
    --os-neutron-lbaas-install=y \
    --cinder-volumes-create=n \
    --keystone-admin-passwd=linux

เครื่อง host

Terminal2::

      //install openstack client
      ## Install openstack client [on host]
      sudo dnf install python-{openstack,keystone,nova,neutron,glance,cinder,\
      swift,heat,ceilometer}client
      ## create folder
      cd ~ && mkdir openstackrc && cd openstackrc

      ##create file ชื่อ admin_rc_v2 (เป็นชื่ออะไรก็ได)
      cat << RC > admin_rc_v2
      unset OS_SERVICE_TOKEN
      export OS_USERNAME=admin
      export OS_PASSWORD=linux
      export OS_AUTH_URL=http://10.10.10.10:5000/v2.0
      export PS1='[\u@\h \W(keystone_admin)]\$ '
      export OS_TENANT_NAME=admin
      export OS_REGION_NAME=RegionOne
      RC
      ## Test
      source admin_rc_v2
      openstack user list
