#!/bin/bash
. ~/.bashrc

#��������ֵ maxcount����ʱ�ļ����� projectmonitorfile
maxcount=100000
projectmonitorfile="/tmp/projectmonitorfile"
#�����ʱ�ļ�
>$projectmonitorfile
curtime=`date "+%Y-%m-%d %H:%M:%S"`


#��host��port �ɶ�д��socket���ӣ����ļ�������3����
exec 3<>/dev/tcp/10.245.0.94/10003


function monitor_gtftkafka()
{
#����ѯ�ļ�¼д���ļ�
grep record /tmp/check.txt  > $projectmonitorfile
#����ѭ�����ļ�������Ϊ���룬����ÿһ�С�
while read LINE
do
echo "LINE=$LINE"
tag=`echo $LINE| awk '{print $3}'`

if [ "$tag" -gt $maxcount ];then
  echo "group=$group,tag=$tag|"
  #������д���ļ�������3�������͵���Ӧ��ip �˿�
  echo "18501973523,13021150878; �澯����:����ԤԼ��ar_pro_status_date_info���,��������=$tag;��ֵ=$maxcount �澯ʱ��=$curtime <BOCO_SMSEND>\r\n" >&3
fi
done < $projectmonitorfile
}


monitor_gtftkafka


#�رձ�׼���
exec 3>&-
#�رձ�׼����
exec 3<&-

sleep 15
