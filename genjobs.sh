#!/bin/bash 
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
for node in sky-app-1 sky-app-2 sky-app-3 sky-app-4 
do
echo " "
echo "*************  $node *************" ;
echo " "


userjobs=`(ssh root@$node 'ps -ef | grep -v root | grep -v oasprod | grep -v as_cron | grep -v oracle | grep -v dbus | grep -v smmsp | grep -v ntp | grep -v rpc | grep -v named | grep -v UID' )`;
# echo "userjobs ... $userjobs"
# echo "length ... ${#userjobs}"

if [ ${#userjobs} -gt 1 ]
then
#echo "FIRST IF - THEN"
usertime=`(echo $userjobs | awk '{print $5}')`;
userjobsstart=${usertime:0:1}

       if [[ "$userjobsstart" == [0-9] ]]
       then
#       echo "          SECOND IF THEN"
       echo "             These jobs were started today at $usertime ..."
       echo " "
       echo "$userjobs"
       else
          echo "                    Second if then else"
          echo "number ......  $userjobsstart"
          echo " -----------------------------------------"
          echo " Please review these older jobs ... "
          echo " $userjobs"
          echo " -----------------------------------------"
          echo "$userjobs" | mail -s " Older Genjobs ..." kmullins@mit.edu 

       fi

else
   echo "no older jobs "
fi
done
