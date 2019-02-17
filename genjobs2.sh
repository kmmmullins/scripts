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
echo $node;
userjobs=`(ssh root@$node 'ps -ef | grep -v root | grep -v oasprod | grep -v as_cron | grep -v oracle | grep -v dbus | grep -v smmsp | grep -v ntp | grep -v rpc | grep -v named | grep -v UID' )`;
usertime=`(echo $userjobs | awk '{print $5}')`;
userjobsstart=${usertime:0:1}

echo "$userjobs"
echo "$userjobsstart"


if [[ "$userjobsstart" == [0-9] ]]
then
echo "number $userjobsstart"
else
     if [ !-z $userjobsstart ]
     then
          echo "number ......  $userjobsstart"
          echo " Please review ... $userjobs"
     fi
fi
done
