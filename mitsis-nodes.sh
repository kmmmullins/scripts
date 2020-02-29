#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
for node in  sky-app-1  sky-app-2 sky-app-3 sky-app-4 sky-app-5 sky-app-6 sky-db-2
do
echo $node;
ssh root@$node 'uptime';
done
