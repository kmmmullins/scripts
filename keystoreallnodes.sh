#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
for node in earth-app-1 earth-app-11 earth-app-21 earth-cafe-1 earth-vault-2 earth-works-1 loompa oompa sea-app-1 sea-app-11 sea-app-12 sea-app-2 sea-app-21 sea-app-22 sea-cafe-1 sea-cafe-2 sea-chart sea-db-1 sea-db-3 sea-vault sea-works-1 sea-works-2 sea-works-3 sky-app-1 sky-app-11 sky-app-12 sky-app-2 sky-app-21 sky-app-22 sky-cafe-1 sky-cafe-2 sky-db-1 sky-db-3 sky-works-3 ua-qa-1 ua-qa-2 ua-qa-3
do
echo $node;
ssh root@$node 'ls -ls /oracle/ora_app/*/j2ee/home/config/*keystore*';
done
