#!/bin/bash
source ~/.bashrc

maxcount=-1
gtftthread="/tmp/gtftthread"
>$gtftthread
curtime=`date "+%Y-%m-%d %H:%M:%S"`
exec 3<>/dev/tcp/10.245.0.94/10003

function monitor_gtftthread()
{
/opt/ansible/packet/telnet_test.exp|grep NATIVE > $gtftthread
while read LINE
do
echo "LINE=$LINE"
group=`echo $LINE| awk '{print $4}'`
tag=`echo $LINE| awk '{print $2}'`

if [ "$tag" -gt $maxcount ];then
  echo "group=$group,tag=$tag|"
  echo "18501973523,13021150878; 告警内容:gtft线程监控,$group 线程堆积任务数=$tag,阈值:200 告警 $curtime <BOCO_SMSEND>\r\n" >&3
fi
done < $gtftthread
}

monitor_gtftthread
exec 3>&-
exec 3<&-

sleep 6
