#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
#for node in earth-app-1 earth-app-11 earth-app-21 earth-cafe-1 earth-vault-2 earth-works-1 loompa oompa sea-app-1 sea-app-11 sea-app-12 sea-app-2 sea-app-21 sea-app-22 sea-cafe-1 sea-cafe-2 sea-chart sea-db-1 sea-db-3 sea-vault sea-works-1 sea-works-2 sea-works-3 sky-app-1 sky-app-11 sky-app-12 sky-app-2 sky-app-21 sky-app-22 sky-cafe-1 sky-cafe-2 sky-db-1 sky-db-3 sky-works-3 ua-qa-1 ua-qa-2 ua-qa-3
for node in earth-app-2 earth-app-3  earth-app-5 earth-app-6 stusys-dev-app-1 stusys-dev-app-2 stusys-test-app-1 stusys-test-app-2 stusys-test-app-3 stusys-test-app-4 sea-app-1 sea-app-2 sea-app-5 sea-app-6 oas-test-app-1 oas-test-app-2 sky-app-1 sky-app-2 sky-app-5 sky-app-6 stusys-prod-app-1 stusys-prod-app-2 stusys-prod-app-3 stusys-prod-app-4
do
echo $node;
ssh root@$node 'cat /home/logs/.k5login | wc';
ssh root@$node 'grep veera /home/logs/.k5login ';
ssh root@$node 'grep msdcunha /home/logs/.k5login ';
ssh root@$node 'grep preethim /home/logs/.k5login ';
done
