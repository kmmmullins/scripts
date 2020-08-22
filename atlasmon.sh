#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
for node in atlas-prod-app-1 atlas-prod-app-2 atlas-prod-app-3 atlas-prod-app-4 admsys-prod-app-1 admsys-prod-app-2 admsys-prod-app-3 admsys-prod-app-4 admsys-prod-app-5 admsys-prod-app-6 finsys-prod-app-1 finsys-prod-app-2 
do

echo $node;
ssh root@$node 'uptime';
ssh root@$node 'free ';
echo $node;
done
