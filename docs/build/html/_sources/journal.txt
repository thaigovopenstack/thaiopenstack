Journalclt
==========

Command  list fieldname ``journalctl fieldname=``
::

    journalctl <Tab><Tab> 
    _AUDIT_LOGINUID=             _HOSTNAME=                   SYSLOG_PID=
    _AUDIT_SESSION=              _KERNEL_DEVICE=              _SYSTEMD_CGROUP=
    _BOOT_ID=                    _KERNEL_SUBSYSTEM=           _SYSTEMD_OWNER_UID=
    _CAP_EFFECTIVE=              _MACHINE_ID=                 _SYSTEMD_SESSION=
    _CMDLINE=                    MESSAGE=                     _SYSTEMD_SLICE=
    CODE_FILE=                   MESSAGE_ID=                  _SYSTEMD_UNIT=
    CODE_FUNC=                   __MONOTONIC_TIMESTAMP=       _SYSTEMD_USER_UNIT=
    CODE_LINE=                   _PID=                        _TRANSPORT=
    _COMM=                       PRIORITY=                    _UDEV_DEVLINK=
    COREDUMP_EXE=                __REALTIME_TIMESTAMP=        _UDEV_DEVNODE=
    __CURSOR=                    _SELINUX_CONTEXT=            _UDEV_SYSNAME=
    ERRNO=                       _SOURCE_REALTIME_TIMESTAMP=  _UID=
    _EXE=                        SYSLOG_FACILITY=             
    _GID=                        SYSLOG_IDENTIFIER= 

    journalctl _UID=1000 _SYSTEMD_UNIT=avahi-daemon.service _SYSTEMD_UNIT=crond.service

Display logs by date
--------------------
::

    date
    Tue Jul 12 08:15:32 ICT 2016

    journalctl --since "2016-7-12 8:00:00"
    -- Logs begin at Sat 2016-06-25 22:42:25 ICT, end at Tue 2016-07-12 08:15:52 ICT. --
    Jul 12 08:01:01 localhost.localdomain CROND[26348]: (root) CMD (run-parts /etc/cron.hourly)
    Jul 12 08:01:01 localhost.localdomain run-parts[26351]: (/etc/cron.hourly) starting 0anacron
    Jul 12 08:01:01 localhost.localdomain run-parts[26357]: (/etc/cron.hourly) finished 0anacron


    journalctl --since yesterday
    journalctl --since "2016-7-12" --until "1 hours ago"

Displaying Logs by Unit or Service
----------------------------------
::


    journalctl -u sshd.service
    journalctl -u sshd.service  --since "2016-7-12 7:00:00"  --untill "2016-7-12 8:00:00"

Displaying Logs by User or Group
--------------------------------
::

    id admin
    uid=1000(admin) gid=1000(admin) groups=1000(admin),10(wheel),982(libvirt)
    journalctl _UID=1000


Displaying Logs by Process ID
-----------------------------
::

    ps -ef | grep http
    apache    1210  1101  0 Jul11 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
    journalctl _PID=1210


Displaying Kernel Logs
----------------------
::

    journalctl -k
    -- Logs begin at Sat 2016-06-25 22:42:25 ICT, end at Tue 2016-07-12 08:33:19 ICT. --
    Jul 11 18:40:22 localhost.localdomain kernel: microcode: microcode updated early to revision 0x8a, 
    Jul 11 18:40:22 localhost.localdomain kernel: Linux version 4.6.3-300.fc24.x86_64 (mockbuild@bkerne

Displaying Logs Since Last Boot
-------------------------------
::

    journalctl -b


Displaying Logs by Priority
---------------------------
0: emerg
1: alert
2: critical
3: error
4: warning
5: notice
6: info
7: debug

:: 
    
    journalctl -p 4
    journalctl -p 3 -b
    journalctl -p warning --since "2016-7-12 7:00:00"


Tailing or Following the Log
----------------------------
::

    journalctl -f
    journalctl -n        (10line default)
    journalctl -n 50 -f
    
