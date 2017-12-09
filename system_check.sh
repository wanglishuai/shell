#!/bin/sh
#The program for checking linux system envirmoent sets.
#ls "$1" | grep / |sed 's/://g' 
#echo $1
#export LANG=en_US.UTF-8
temp_ip=$1
#check system processe limit and file limit
processes=`ulimit -a | grep processes | awk '{print $5}'`
files=`ulimit -a | grep files | awk '{print $4}'`
echo "The process limit of system is $processes."> /opt/ansible/packet/system_reports
echo "The file limit of system is $files.">> /opt/ansible/packet/system_reports

#check ntp server IP of system is right or wrong.
ntpserver=`grep "^server" /etc/ntp.conf | awk '{print $2}'`
if [ "$ntpserver" == "$1" ]
then
   echo "OK:The ntp server ip of System is $ntpserver, It's right." >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The ntp server ip of System is $ntpserver, It's wrong,It should be seted $1." >> /opt/ansible/packet/system_reports
fi

#check dns server IP of system is right or wrong
dnsserver=(`grep "^nameserver" /etc/resolv.conf | awk '{print $2}'`)
if [ "${dnsserver[0]}" == "$2" ]
then
   echo "OK:The DNS server1 ip of System is ${dnsserver[0]}, It's right." >> /opt/ansible/packet/system_reports
   hostIP=`ifconfig | grep "inet addr" | grep -v 127.0.0.1  |sed -nr "s/.*addr:(.*)Bcast.*/\1/p"` 
   if [ $hostIP == ${dnsserver[0]} ]
   then
     service named status >>/dev/null
     temp=$?
     if [ "$temp" == 0 ]
     then
       echo "OK:This server is DNS server1,It's running." >> /opt/ansible/packet/system_reports
     else
       echo "FAIL:This server is DNS server1,It's stopped." >> /opt/ansible/packet/system_reports
     fi
   fi
   nslookup ${dnsserver[0]} >>/dev/null
   temp=$?
   if [ "$temp" == 0 ]
   then 
     echo "OK:The DNS server is in use." >> /opt/ansible/packet/system_reports
   else
     echo "FAIL:The DNS server is invalid, Please check it." >> /opt/ansible/packet/system_reports
   fi
else
   echo "FAIL:The DNS server1 ip of System is ${dnsserver[0]}, It's wrong,It should be seted $2." >> /opt/ansible/packet/system_reports
fi

if [ "${dnsserver[1]}" == "$3" ]
then
   echo "OK:The DNS server2 ip of System is ${dnsserver[1]}, It's right." >> /opt/ansible/packet/system_reports
   hostIP=`ifconfig | grep "inet addr" | grep -v 127.0.0.1  |sed -nr "s/.*addr:(.*)Bcast.*/\1/p"` 
   if [ $hostIP == ${dnsserver[1]} ]
   then
     service named status>>/dev/null
     temp=$?
     if [ "$temp" == 0 ]
     then
       echo "OK:This server is DNS server2,It's running." >> /opt/ansible/packet/system_reports
     else
       echo "FAIL:This server is DNS server2,It's stopped." >> /opt/ansible/packet/system_reports
     fi
   fi
   nslookup ${dnsserver[1]} >>/dev/null
   temp=$?
   if [ "$temp" == 0 ]
   then 
     echo "OK:The DNS server is in use." >> /opt/ansible/packet/system_reports
   else
     echo "FAIL:The DNS server is invalid, Please check it." >> /opt/ansible/packet/system_reports
   fi
else
   echo "FAIL:The DNS server2 ip of System is ${dnsserver[1]}, It's wrong,It should be seted $3." >> /opt/ansible/packet/system_reports
fi

# check ruby to be installed
ruby_packet=`rpm -qa | grep ruby-1.8.7.374-4.el6_6.x86_64`
if [ $ruby_packet == "ruby-1.8.7.374-4.el6_6.x86_64" ]
then
  echo "OK:The ruby packet is installed correctly." >> /opt/ansible/packet/system_reports
else
  echo "FAIL:The ruby packet is installed wrongly,please install it witch ansible progame or yum order." >> /opt/ansible/packet/system_reports
fi

# check rubygems to be installed
rubygems_packet=`rpm -qa | grep rubygems-1.3.7-5.el6.noarch`
if [ $rubygems_packet == "rubygems-1.3.7-5.el6.noarch" ]
then
  echo "OK:The rubygems packet is installed correctly." >> /opt/ansible/packet/system_reports
else
  echo "FAIL:The rubygems packet is installed wrongly,please install it witch ansible progame or yum order." >> /opt/ansible/packet/system_reports
fi

# check ruby-rdoc to be installed
ruby_rdoc_packet=`rpm -qa | grep ruby-rdoc-1.8.7.374-4.el6_6.x86_64`
if [ $ruby_rdoc_packet == "ruby-rdoc-1.8.7.374-4.el6_6.x86_64" ]
then
  echo "OK:The ruby-rdoc packet is installed correctly." >> /opt/ansible/packet/system_reports
else
  echo "FAIL:The ruby-rdoc packet is installed wrongly,please install it witch ansible progame or yum order." >> /opt/ansible/packet/system_reports
fi

# check redis.gem to be installed
redis_gem_packet=`gem list | grep redis | awk '{print $1}'`
if [ $redis_gem_packet == "redis" ]
then
  echo "OK:The redis.gem packet is installed correctly." >> /opt/ansible/packet/system_reports
else
  echo "FAIL:The redis.gem packet is installed wrongly,please install it witch ansible progame or gem order." >> /opt/ansible/packet/system_reports
fi

# check jdk1.8 to be installed
jdk_1_8_packet=`rpm -qa | grep jdk1.8.0_102-1.8.0_102-fcs.x86_64`
if [ $jdk_1_8_packet == "jdk1.8.0_102-1.8.0_102-fcs.x86_64" ]
then
  echo "OK:The jdk1.8 packet is installed correctly." >> /opt/ansible/packet/system_reports
else
  echo "FAIL:The jdk1.8 packet is installed wrongly,please install it witch ansible progame or rpm order." >> /opt/ansible/packet/system_reports
fi

# check jdk1.7 to be installed
jdk_1_7_packet=`rpm -qa | grep jdk-1.7.0_79-fcs.x86_64`
if [ $jdk_1_7_packet == "jdk-1.7.0_79-fcs.x86_64" ]
then
  echo "OK:The jdk1.7 packet is installed correctly." >> /opt/ansible/packet/system_reports
else
  echo "FAIL:The jdk1.7 packet is installed wrongly,please install it witch ansible progame or rpm order." >> /opt/ansible/packet/system_reports
fi

#check iptables to be closed
service iptables status >/dev/null
iptables_temp=$?
#echo $iptables_temp
if [ $iptables_temp = "0" ]
then
   echo "FAIL:The iptables is in use, please stop it with the order of \"service iptables stop\"." >> /opt/ansible/packet/system_reports
else
   echo "OK:The iptables is closed." >> /opt/ansible/packet/system_reports
fi
iptables_1=`chkconfig --list | grep iptables | awk '{print $4}'`
iptables_2=`chkconfig --list | grep iptables | awk '{print $5}'`
iptables_3=`chkconfig --list | grep iptables | awk '{print $6}'`
iptables_4=`chkconfig --list | grep iptables | awk '{print $7}'`
#if [ $iptables_1 = "2:off" ]
if [[ $iptables_1 = "2:off" && $iptables_2 = "3:off" && $iptables_3 = "4:off" && $iptables_4 = "5:off" ]]
then
  echo "OK:The iptables is closed for ever." >> /opt/ansible/packet/system_reports
else
  echo "FAIL:The iptables isn't closed for ever, please close off it with the order \"chkconfig iptables off\"." >> /opt/ansible/packet/system_reports
fi

#check xdpp user to be created
xdpp_user=`grep xdpp /etc/group | awk -F ':' '{print $1}'`

if [ $xdpp_user = "xdpp" ]
then
  echo "OK:The xdpp user is created." >> /opt/ansible/packet/system_reports
else
  echo "FAIL:The xdpp user isn't created, please creat xdpp user now." >> /opt/ansible/packet/system_reports
fi


#check Selinux to be closed
enforce=`getenforce` 
if [ "$enforce"x = "Disabled"x -o "$enforce"x = "Permissive"x ]
then
   echo "OK:The Selinux is closed" >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The Selinux is enforcing,Please close off it with the order \"setenforce 0\" or modify the config /etc/selinux/config." >> /opt/ansible/packet/system_reports
fi

#check Selinux to be closed for ever
enforceconfig=`grep "^SELINUX" /etc/selinux/config| awk -F "=" '{print $2}'`
if [ "$enforceconfig"x = "disabled"x -o "$enforceconfig"x = "permissive"x ]
then
   echo "OK:The Selinux is closed for ever" >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The Selinux is enforcing,Please close off it with the order \"setenforce 0\" or modify the config /etc/selinux/config." >> /opt/ansible/packet/system_reports
fi

#check hostname to be modifyed
hostname=`hostname`
hostnameconfig=`grep "^HOSTNAME" /etc/sysconfig/network| awk -F "=" '{print $2}' `
if [ "$hostname"x = "$4"x -a "$hostnameconfig"x = "$4"x ]
then
   echo "OK:The hostname is modifyed" >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The hostname is not modifyed,Please close off it with the order \"hostname HOSTNAME\" or modify the config /etc/sysconfig/network." >> /opt/ansible/packet/system_reports
fi
#check yum.conf 
sslverify=`grep "^sslverify" /etc/yum.conf|awk -F "=" '{print $2}'`
if [ "$sslverify"x = "False"x ]
then
   echo "OK:The sslverify in yum.conf is closed " >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The sslverify is not setted false ,Please mofify config /etc/yum.conf." >> /opt/ansible/packet/system_reports
fi


#net.ipv4.tcp_keepalive_intvl temporarily
temp_tcp_keepalive_invel=`sysctl -a|grep net.ipv4.tcp_keepalive_intvl|awk -F '=' '{print $2}'|sed s'/ //'`
if [ "$temp_tcp_keepalive_invel"x = "15"x ]
then
   echo "OK:The net.ipv4.tcp_keepalive_intvl is setted to 15 temporarily." >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The net.ipv4.tcp_keepalive_intvl is setted to $tcp_keepalive_invel ,not setted to 15(recommended value),please check the config /etc/sysctl.conf" >> /opt/ansible/packet/system_reports
fi

#net.ipv4.tcp_keepalive_intvl
tcp_keepalive_invel=`grep "^net.ipv4.tcp_keepalive_intvl" /etc/sysctl.conf |awk -F "=" '{print $2}'|sed s'/ //'`
if [ "$tcp_keepalive_invel"x = "15"x ]
then
   echo "OK:The net.ipv4.tcp_keepalive_intvl is setted to 15." >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The net.ipv4.tcp_keepalive_intvl is setted to $tcp_keepalive_invel ,not setted to 15(recommended value),please check the config /etc/sysctl.conf" >> /opt/ansible/packet/system_reports
fi

#net.ipv4.tcp_keepalive_probes temporarily
temp_tcp_keepalive_probes=`sysctl -a|grep net.ipv4.tcp_keepalive_probes|awk -F '=' '{print $2}'|sed s'/ //'`
if [ "$temp_tcp_keepalive_probes"x = "3"x ]
then
   echo "OK:The net.ipv4.tcp_keepalive_probes is setted to 3 temporarily." >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The net.ipv4.tcp_keepalive_probes is setted to $tcp_keepalive_probes,but not setted to 3(recommended value),please check the config /etc/sysctl.conf" >> /opt/ansible/packet/system_reports
fi

#net.ipv4.tcp_keepalive_probes
tcp_keepalive_probes=`grep "^net.ipv4.tcp_keepalive_probes" /etc/sysctl.conf |awk -F "=" '{print $2}'|sed s'/ //'`
if [ "$tcp_keepalive_probes"x = "3"x ]
then
   echo "OK:The net.ipv4.tcp_keepalive_probes is setted to 3." >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The net.ipv4.tcp_keepalive_probes is setted to $tcp_keepalive_probes,but not setted to 3(recommended value),please check the config /etc/sysctl.conf" >> /opt/ansible/packet/system_reports
fi

#net.ipv4.tcp_keepalive_time temporarily
temp_tcp_keepalive_time=`sysctl -a|grep net.ipv4.tcp_keepalive_time|awk -F '=' '{print $2}'|sed s'/ //'`
if [ "$temp_tcp_keepalive_time"x = "60"x ]
then
   echo "OK:The net.ipv4.tcp_keepalive_time is setted to 60 temporarily." >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The net.ipv4.tcp_keepalive_time is setted to $tcp_keepalive_time ,but not setted to 60(recommended value),please check the config /etc/sysctl.conf" >> /opt/ansible/packet/system_reports
fi

#net.ipv4.tcp_keepalive_time
tcp_keepalive_time=`grep "^net.ipv4.tcp_keepalive_time" /etc/sysctl.conf |awk -F "=" '{print $2}'|sed s'/ //'`
if [ "$tcp_keepalive_time"x = "60"x ]
then
   echo "OK:The net.ipv4.tcp_keepalive_time is setted to 60." >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The net.ipv4.tcp_keepalive_time is setted to $tcp_keepalive_time ,but not setted to 60(recommended value),please check the config /etc/sysctl.conf" >> /opt/ansible/packet/system_reports
fi

#check transparent_hugepage to be setted to never
transparent_hugepage=`cat /sys/kernel/mm/transparent_hugepage/defrag|awk '{print $3}'`
if [ "$transparent_hugepage"x = "[never]"x ]
then
   echo "OK:The transparent_hugepage is setted to never temporarily." >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The transparent_hugepage is setted to $transparent_hugepage ,but not setted to never(recommended value)." >> /opt/ansible/packet/system_reports
fi
#check transparent_hugepage add to /etc/rc.local

transparent_hugepage_flag=`grep "echo never > /sys/kernel/mm/transparent_hugepage/defrag" /etc/rc.local |wc -l`
if [ "$transparent_hugepage_flag"x = "1"x ]
then
   echo "OK:The transparent_hugepage is setted to never for ever" >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The transparent_hugepage[never] is not setted to never for ever" >> /opt/ansible/packet/system_reports
fi

#vm.swappiness
swappiness=`grep "^vm.swappiness" /etc/sysctl.conf |awk -F "=" '{print $2}'|sed s'/ //'`
if [ "$swappiness"x = "0"x ]
then
   echo "OK:The vm.swappiness is setted to 0." >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The vm.swappiness is setted to $swappiness,but not setted to 0(recommended value),please check the config /etc/sysctl.conf" >> /opt/ansible/packet/system_reports
fi

#vm.overcommit_memory
overcommit_memory=`grep "^vm.overcommit_memory" /etc/sysctl.conf |awk -F "=" '{print $2}'|sed s'/ //'`
if [ "$overcommit_memory"x = "1"x ]
then
   echo "OK:The vm.overcommit_memory is setted to 1." >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The vm.overcommit_memory is setted to $overcommit_memory,but not setted to 1(recommended value),please check the config /etc/sysctl.conf" >> /opt/ansible/packet/system_reports
fi

#check oracle-client
if [ -d /opt/xdpp/oracle/instantclient_11_2 ]
then 
   echo "OK: The oracle client is installed successfully."  >> /opt/ansible/packet/system_reports
else
   echo "FAIL: The oracle client is not installed ,Please Check it ." >> /opt/ansible/packet/system_reports
fi

#check NLS_LANG
nlslang=`grep "^export NLS_LANG" /etc/profile |awk -F "=" '{print $2}'|sed s'/ //'`
if [ "$nlslang"x = "AMERICAN_AMERICA.ZHS16GBK"x ]
then
   echo "OK:The NLS_LANG is setted to AMERICAN_AMERICA.ZHS16GBK." >> /opt/ansible/packet/system_reports
else
   echo "FAIL:The NLS_LANG is setted to $nlslang ,but not setted to AMERICAN_AMERICA.ZHS16GBK(recommended value),please check the config /etc/profile" >> /opt/ansible/packet/system_reports
fi

