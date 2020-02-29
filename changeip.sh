#!/bin/bash
# Changeip.sh is used to change the IP's in i2b2

var1=`grep Reverse /home/kmullins/tmp/proxy.txt | awk -F/   '{print $5}' `
leng=`expr length "$var1"`
checklength=${#var1}
cl=`expr ${checklength}`

function changeips (){ 
                         echo " in changeips ... "
			 echo " ..."
}

if [ -z $1 ]
then
	echo "You should pass in the current ip external address as P1. The program will use your current ip address"
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

	
read -p "Do you want to change IP's (yes or no)" choice
case "$choice" in
	 Yes|YES|yes|y) echo "Yes, Change the IPs"
		 
		 echo " doing something"

		 changeips
                 exit

		 ;;
	 No|NO|no|n)    echo "No, do not change the IPs";;
	 *) echo "Bad choice" ;;
esac
fi





