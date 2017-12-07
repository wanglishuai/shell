#!/bin/bash
. ~/.bashrc

#定义监控阈值 maxcount，临时文件名称 projectmonitorfile
maxcount=100000
projectmonitorfile="/tmp/projectmonitorfile"
#清空临时文件
>$projectmonitorfile
curtime=`date "+%Y-%m-%d %H:%M:%S"`


#打开host的port 可读写的socket连接，与文件描述符3连接
exec 3<>/dev/tcp/10.245.0.94/10003


function monitor_gtftkafka()
{
#将查询的记录写入文件
grep record /tmp/check.txt  > $projectmonitorfile
#以下循环以文件内容作为输入，遍历每一行。
while read LINE
do
echo "LINE=$LINE"
tag=`echo $LINE| awk '{print $3}'`

if [ "$tag" -gt $maxcount ];then
  echo "group=$group,tag=$tag|"
  #将内容写入文件描述符3，即发送到对应的ip 端口
  echo "18501973523,13021150878; 告警内容:工程预约表ar_pro_status_date_info监控,数据条数=$tag;阈值=$maxcount 告警时间=$curtime <BOCO_SMSEND>\r\n" >&3
fi
done < $projectmonitorfile
}


monitor_gtftkafka


#关闭标准输出
exec 3>&-
#关闭标准输入
exec 3<&-

sleep 15
