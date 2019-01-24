#!/bin/sh

#查询服务器上线程数超过500的进程号，过滤掉 pid < 4000 的进程。
#可能不太严谨，4000以下的大部分为系统进程。
pidlist=`ps -ef |awk '{print $2}'`
for pid in $pidlist
{
   if [ "$pid"x != "PIDx" ];then
     if [ $pid -gt 4000 ];then
         threadnum=`ps -mp $pid |wc -l`
         if [ $threadnum -gt 500 ];then
             echo "$pid: `ps -mp $pid |wc -l`"
         fi
     fi
   fi
}
