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

    vagrant up --provider libvirt

    vagrant status
    Current machine states:

    controller                running (libvirt)
    compute                   running (libvirt)


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


::
    ...
    Applying 10.10.10.10_controller.pp
    10.10.10.10_controller.pp:                           [ DONE ]
    Applying 10.10.10.10_network.pp
    10.10.10.10_network.pp:                              [ DONE ]
    Applying 10.10.10.11_compute.pp
    10.10.10.11_compute.pp:                              [ DONE ]
    Applying Puppet manifests                            [ DONE ]
    Finalizing                                           [ DONE ]

     **** Installation completed successfully ******

    Additional information:
     * A new answerfile was created in: /root/packstack-answers-20161012-011347.txt
     * Time synchronization installation was skipped. Please note that unsynchronized time on server instances might be problem for some OpenStack components.
     * File /root/keystonerc_admin has been created on OpenStack client host 10.10.10.10. To use the command line tools you need to source the file.
     * To access the OpenStack Dashboard browse to http://10.10.10.10/dashboard .
    Please, find your login credentials stored in the keystonerc_admin in your home directory.
     * Because of the kernel update the host 10.10.10.11 requires reboot.
     * Because of the kernel update the host 10.10.10.10 requires reboot.
     * The installation log file is available at: /var/tmp/packstack/20161012-011346-Rr34Lj/openstack-setup.log
     * The generated manifests are available at: /var/tmp/packstack/20161012-011346-Rr34Lj/manifests
    [root@controller ~]#

.. note::  หากมีความผิดพลาดแล้วจะต้อง run packstack ใหม่ให้ สั่งคำสั่ง จาก answerfile
ที่สร้างขึ้น

    ::

        [root@controller ~]# ls
        packstack-answers-20161012-011347.txt
        [root@controller ~]# packstack --answer-file=packstack-answers-20161012-011347.txt
        
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
