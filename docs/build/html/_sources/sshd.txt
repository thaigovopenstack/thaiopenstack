=====================
SSH Server On CentOS7
=====================

ssh
===


Basic Command
*************
install
-------
::

	dnf install -y openssh-server openssh-clients
	systemctl start sshd
	systemctl enable sshd
	firewall-cmd --permanent --add-service ssh
	firewall-cmd --reload

/etc/ssh/sshd_config
--------------------
::

	vim  /etc/ssh/sshd_config  

	19:#ListenAddress 0.0.0.0
	49:PermitRootLogin yes
	55:#PubkeyAuthentication yes
	79:PasswordAuthentication yes


	systemctl reload sshd
	systemctl status sshd

Keyauthen
---------
สร้าง key ให้แก่  user ในที่นี้สร้าง key ให้แก่ user admin
:: 

	su - admin
	ssh-keygen -t rsa -b 4096
	ls ~/.ssh/


ssh remote login with key
-------------------------
copy public key  ไปยัง targetserver (จับคู่แลก ip)
::

    su - admin 
	ssh-copy-id   -i ~/.ssh/id_rsa.pub  admin@ip_targetserver
    ssh admin@ip_targetserver

บนเครื่อง Target Server
::

	vim  /etc/ssh/sshd_config 

	PasswordAuthentication no
	PubkeyAuthentication yes

restart
::

	systemctl restart sshd


