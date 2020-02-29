#!/bin/bash
# Changeip.sh is used to change the IP's in i2b2

#var1=`grep Reverse /etc/httpd/conf.d/i2b2_proxy.conf | awk -F/   '{print $5}' `
var1=`docker exec i2b2-web /bin/bash -c " grep Reverse /etc/httpd/conf.d/i2b2_proxy.conf"`
leng=`expr length "$var1"`
checklength=${#var1}
cl=`expr ${checklength}`

function changeips (){ 
                         echo " in changeips ... "
			 echo " ..."

                         echo " in changeips ... "
			 echo " ... "
			 echo " changeing IP from the previous ip $oldip "
			 echo " to new extenal ip $IP"
}

if [ -z $1 ]
then
	echo "If you are on AWS you should pass in the external IP address as P1. The program will use your current ip address"
        IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
        echo "No P1 - Using IP: $IP"
else
	
        IP=$1
        echo "using given IP: $1"
fi


if [ $cl -gt 15 ];
then
	echo " The IP includes a reference to a port $var1 "
	echo " Removing port reference"
	oldip=` echo $var1 | awk -F: '{print $1}' `
	echo $oldip
else
	echo " Length is ok $leng"
	oldip="$var1"
	echo "OLDIP ... $oldip"

fi



if [ ${IP} = ${oldip} ] 
then
	echo "$IP and $oldip are the same"
else 

	echo "$IP and $oldip are NOT the same"
	echo "$IP and $oldip are NOT the same"
	echo "$IP and $oldip are NOT the same"

	
read -p "Do you want to update IP's (yes or no)" choice
case "$choice" in
	 Yes|YES|yes|y) echo "Yes, update the IPs"
		 
		 echo " Updating"

		 changeips
                 exit

		 ;;
	 No|NO|no|n)    echo "No, do not change the IPs";;
	 *) echo "Bad choice" ;;
esac
fi





