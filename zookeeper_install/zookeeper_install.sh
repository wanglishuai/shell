#!/bin/sh

servernum=`cat ./host.config|wc -l`
flag=`expr $servernum % 2`
workdir="/opt/ansible"
if [[ $servernum -lt 3 ||  $flag -eq 0 ]]
then 
   echo -e "\033[0;31mA minimum of three servers are required!\033[0m"
   echo -e "\033[0;31mYou Must have an odd number of servers,like 3,5,7...\033[0m"
   exit
fi

function install_zookeeper()
{
    if [ -a ${workdir}/packet/zookeeper-3.4.8.tar.gz ]
    then
        while read LINE  
        do
            destip=`echo $LINE | awk '{print $1}'`
            echo -e "\033[0;32mCopy the packet to ${destip}\033[0m"
            ssh  -n root@${destip} "mkdir -p /opt/zookeeper"
            scp ${workdir}/packet/zookeeper-3.4.8.tar.gz root@${destip}:/opt/zookeeper
            ssh  -n root@${destip} "ls -lart /opt/zookeeper/zookeeper-3.4.8.tar.gz  > /dev/null && cd /opt/zookeeper && tar -zxvf zookeeper-3.4.8.tar.gz > /dev/null"
        done < ./host.config
    else
        echo -e "\033[0;31mYou should copy the 'zookeeper-3.4.8.tar.gz' to Directory /opt/ansible/packet\033[0m"
        exit
    fi
}

function modify_zooconfig()
{
     cat  zoo_template.cfg  >  zoo.cfg
     num=1
     while read LINE
     do
         destip=`echo $LINE | awk '{print $1}'`
         echo server.${num}=${destip}:2888:3888 >> ./zoo.cfg
         let num=num+1
     done < ./host.config

     num=1
     while read LINE  
     do
         destip=`echo $LINE | awk '{print $1}'`
         existflag=`ssh  -n root@${destip} "ls -d /opt/zookeeper/zookeeper-3.4.8 |wc -l"`
         if [ "$existflag"x = "1"x ]
         then 
             scp ./zoo.cfg root@${destip}:/opt/zookeeper/zookeeper-3.4.8/conf
             ssh -n root@${destip} "mkdir -p /opt/zookeeper/zookeeper-3.4.8/data && cd /opt/zookeeper/zookeeper-3.4.8/data && echo ${num} >> myid"
         else
             echo -e "\033[0;31mmake sure you had install zookeeper successfully!\033[0m"
             exit
         fi
         let num=num+1
     done < ./host.config
}


function start_zookeeper()
{
    while read LINE  
     do  
         destip=`echo $LINE | awk '{print $1}'`
         existflag=`ssh  -n root@${destip} "ls -d /opt/zookeeper/zookeeper-3.4.8 |wc -l"`
         if [ "$existflag"x = "1"x ]
         then 
             ssh -n root@${destip} "cd /opt/zookeeper/zookeeper-3.4.8/bin && chmod +x *sh && ./zkServer.sh start"
         else
             echo -e "\033[0;31mmake sure you had install zookeeper successfully!\033[0m"
             exit
         fi
     done < ./host.config
}

function check_zookeeper()
{
    while read LINE  
     do  
         destip=`echo $LINE | awk '{print $1}'`
         existflag=`ssh  -n root@${destip} "ls -d /opt/zookeeper/zookeeper-3.4.8 |wc -l"`
         if [ "$existflag"x = "1"x ]
         then 
             ssh -n root@${destip} "cd /opt/zookeeper/zookeeper-3.4.8/bin && chmod +x *sh && ./zkServer.sh status"
         else
             echo -e "\033[0;31m make sure you had install zookeeper successfully!\033[0m"
             exit
         fi
     done < ./host.config
}

function check_zookeeper_installed()
{
    while read LINE  
     do  
         destip=`echo $LINE | awk '{print $1}'`
         existflag=`ssh  -n root@${destip} "ls -d /opt/zookeeper/zookeeper-3.4.8 |wc -l"`
         portexistflag=`ssh -n root@${destip} "lsof -i:2181|grep LISTEN |wc -l"`
         if [ "$existflag"x = "1"x ]
         then 
             echo -e "\033[0;31m${destip} --You had install zookeeper?Check  /opt/zookeeper/zookeeper-3.4.8  exist or not! \033[0m"
             exit
         elif [ "$portexistflag"x = "1"x ]
         then
             echo -e "\033[0;31m${destip} --You had install zookeeper,Port 2181 is LISTENING UP\033[0m"
             exit
         else
             echo -e "\033[0;32m${destip} check result is OK! \033[0m"
         fi
     done < ./host.config
    
}

echo -e "\033[0;32mStep 1. Check zookeeper environment\033[0m"
check_zookeeper_installed
echo -e "\033[0;32m |--Check zookeeper environment is OK\033[0m"
echo -e "\033[0;32mStep 2. Begin Install zookeeper ...\033[0m"
install_zookeeper
echo -e "\033[0;32mStep 3. Modify zoo.cfg ...\033[0m"
modify_zooconfig
echo -e "\033[0;32mStep 4. Start zookeeper cluster ...\033[0m"
start_zookeeper
echo -e "\033[0;32mStep 5. Check zookeeper cluster status ...\033[0m"
sleep 10 
check_zookeeper

