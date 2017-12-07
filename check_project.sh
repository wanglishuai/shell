#!/bin/bash
source /home/npmuser/.bashrc
export LANG=zh_CN.utf8
#cd $DB_PATH/bin

############: wlog String  
wlog () {
  wlog_dt=`date "+%Y/%m/%d-%H:%M:%S" `
  echo "${wlog_dt} $1"
}
wlog "Begin to export the sql"
############: db2export
db2 connect to wnms user nmosdb using nmosoptr
echo `db2 "select count(*) from  ar_pro_status_date_info with ur "`

db2 commit work

wlog "export the sql is end"

