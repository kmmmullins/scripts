#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
NOW=$(date +"%m-%d-%Y")
tempfile=/home/kmullins/tmp/sisapp-temp.$NOW
for node in sea-app-1 sea-app-2
do
echo $node;
ssh root@$node "cat /oracle/logs/j2ee/sisapp-secure_error_log" >> $tempfile ;
echo "---------------";
done
echo $tempfile
cat $tempfile

