#!/bin/sh

date=`date +%Y%m%d%H%M%S`
hostname="$2"
if [ $# -lt 2 ]
then
  echo "eg. DNS_setup.sh ip hostname"
  exit
fi
echo "Step.1 Install DNS software "
yum -y install bind  bind-chroot  bind-libs bind-devel bind-utils
echo "Step.2 Modify config /etc/named.conf "
str1="listen-on port"
rstr1="listen-on port 53 { any; };"
str2="allow-query"
rstr2="allow-query     { any; };"
sed -i.$date s/"$str1".*/"$rstr1"/g /etc/named.conf 
sleep 1 
sed -i.$date s/"$str2".*/"$rstr2"/g /etc/named.conf
chown -R root:named /etc/named.conf
echo NETWORKING=yes > /etc/sysconfig/network && echo "HOSTNAME=$hostname" >> /etc/sysconfig/network && hostname $hostname

#hostlist=`cat host.config`
echo "Step.3 Create new zonefile "
sh host.sh $1 $2

echo "Step.4 Restart named service"
cp *zone /var/named/ && chown -R root.named /var/named/*zone
service named restart
chattr -i /etc/resolv.conf 
echo "nameserver $1" > /etc/resolv.conf
chattr +i /etc/resolv.conf 
echo "Step.5 Restart named service following the machine"
chkconfig named on
