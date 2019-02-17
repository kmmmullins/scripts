#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
for node in  sea-app-21 sea-app-22 sky-app-21 sky-app-22 
do
echo ${node};
#ssh root@${node} 'ls -la /home/inside/webapps/apr-changes/build/classes/idd.properties';
ssh root@${node} 'ls -la /home/inside/webapps/apr-changes/src/idd.properties';
done
