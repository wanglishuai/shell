#!/bin/sh


dnshostip="$1"
dnshostname="$2"
dnshostshotname=`echo $2|awk -F '.'  '{print $1}'`
declare -A hostlist
declare -A iplist
declare -A domainlist
declare -A iprpa
declare -A zonefile
while read LINE
do
	#echo "LINE=$LINE"
	hostip=`echo $LINE|awk '{print $1}'`
	hostname=`echo $LINE|awk '{print $2}'`
        domain=`echo $hostname|awk -F '.'  '{print $2"."$3}'`
	ipsection=`echo $hostip|awk -F '.' '{print $1"."$2"."$3}'`
	#echo $domain
	#hostlist[$hostip]=${hostlist[$hostip]}","$hostname
        #iplist[$hostname]=${iplist[$hostname]}","$hostip	
	hostlist[$hostip]=$hostname
        iplist[$hostname]=$hostip	
        domainlist[$domain]=1
	iprpa[$ipsection]=1

done < ./host.config


#for key in  ${!iplist[*]}
#do 
#	echo "$key -> ${iplist[$key]}"
#done

echo "===create zone file start==="
for key in  ${!domainlist[*]}
do 
	touch "$key".zone
	echo '$TTL 86400               ' > "$key".zone
	echo "@     IN SOA  ${dnshostname}. root.${dnshostshotname}.boco.com. (" >> "$key".zone
	echo '                          0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H)    ; minimum' >> "$key".zone
echo " IN NS ${dnshostname}." >> "$key".zone
       echo "${dnshostname} IN   A   ${dnshostip}" >> "$key".zone
   for hostkey in  ${!iplist[*]}
   do 
	#echo "wls===$hostkey"
	subkey=`echo $hostkey |awk -F '.' '{print $2"."$3}'` 
	shotname=`echo $hostkey |awk -F '.' '{print $1}'` 
	if [ "$subkey"x = "$key"x ]
	then
	   echo "$shotname     IN    A   ${iplist[$hostkey]}" >> "$key".zone
	fi
   done
   existflag=`grep $key /etc/named.rfc1912.zones|wc -l`
   if [ "$existflag"x = "0"x ]
   then
      echo "zone \"${key}\" IN {
       type master;
       file \"${key}.zone\";
       allow-update { none; };
       };" >> /etc/named.rfc1912.zones
   fi
   zonefile[${key}]="${key}.zone"
done

for key in  ${!iprpa[*]}
do 
	touch "$key".zone
	echo '$TTL 86400               ' > "$key".zone
        echo "@     IN SOA ${dnshostname}. root.${dnshostshotname}.boco.com. (" >> "$key".zone
	echo '                          0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H)    ; minimum' >> "$key".zone
	echo " IN NS ${dnshostname}." >> "$key".zone
   for ipkey in  ${!hostlist[*]}
   do 
	#echo "wls===$ipkey"
	subkey=`echo $ipkey |awk -F '.' '{print $1"."$2"."$3}'` 
	shotname=`echo $ipkey |awk -F '.' '{print $4}'` 
	if [ "$subkey"x = "$key"x ]
	then
	   echo "$shotname     IN    PTR   ${hostlist[$ipkey]}." >> "$key".zone
	fi
   done
   subkey=`echo $key |awk -F '.' '{print $1"."$2"."$3}'` 
   revsubkey=`echo $key |awk -F '.' '{print $3"."$2"."$1}'`
   revzone="${revsubkey}-addr.arpa"
   existflag=`grep $subkey /etc/named.rfc1912.zones|wc -l`
   if [ "$existflag"x = "0"x ]
   then
      echo "zone \"${revsubkey}.in-addr.arpa\" IN {
       type master;
       file \"${subkey}.zone\";
       allow-update { none; };
       };" >> /etc/named.rfc1912.zones
   fi
   
   zonefile[${revzone}]="${subkey}.zone"
done

for key in  ${!zonefile[*]}
do 
	#echo $key"====="${zonefile[$key]}
	named-checkzone $key ${zonefile[$key]} > ./$key.txt
	checkresult=$?
        if [ "$checkresult"x = "0"x ]
        then
	    echo  "${zonefile[$key]} check result is OK"
        elif [ "$checkresult"x = "1"x ]
        then
	    echo "${zonefile[$key]} check result is not OK"
	    echo "Please check test ${key}.txt for more details"
	fi
done

#add packeges and cloud zone

   existflag=`grep 'zone "cloudera.com"' /etc/named.rfc1912.zones|wc -l`
   if [ "$existflag"x = "0"x ]
   then
      echo "zone \"cloudera.com\" IN {
       type master;
       file \"cloudera.com.zone\";
       allow-update { none; };
       };" >> /etc/named.rfc1912.zones
      
      echo '$TTL    86400'  > /var/named/cloudera.com.zone 

      echo "@       IN SOA  ${dnshostshotname}.cloudera.com. root.${dnshostshotname}.cloudera.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
 IN        NS       ${dnshostshotname}.cloudera.com." > /var/named/cloudera.com.zone
      echo "${dnshostshotname}      IN       A            ${dnshostip}"  >> /var/named/cloudera.com.zone
      echo "archive      IN       A                       ${dnshostip}"  >> /var/named/cloudera.com.zone
      chown -R  root.named /var/named/cloudera.com.zone
   fi
   
   existflag=`grep 'zone "xdpp.boco"' /etc/named.rfc1912.zones|wc -l`
   if [ "$existflag"x = "0"x ]
   then
      echo "zone \"xdpp.boco\" IN {
       type master;
       file \"xdpp.boco.zone\";
       allow-update { none; };
       };" >> /etc/named.rfc1912.zones
       
      echo '$TTL    86400'  > xdpp.boco.zone
      echo "@       IN SOA  ${dnshostshotname}.xdpp.boco. root.${dnshostshotname}.xdpp.boco. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum" >> xdpp.boco.zone
      echo " IN        NS       ${dnshostshotname}.xdpp.boco." >> xdpp.boco.zone
      echo "${dnshostshotname}      IN       A            ${dnshostip}"  >> xdpp.boco.zone
      echo "packages      IN       A                       ${dnshostip}"  >> xdpp.boco.zone
      chown -R  root.named xdpp.boco.zone
   elif [ "$existflag"x = "1"x ]
   then 
      echo "packages      IN       A                       ${dnshostip}"  >> xdpp.boco.zone
   fi  
   
   
   
