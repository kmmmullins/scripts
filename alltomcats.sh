#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
for node in stusys-prod-app-1 stusys-prod-app-2 stusys-prod-app-3 stusys-prod-app-4 esapis-prod-app-1 esapis-prod-app-2 sched-prod-app-1 admsys-prod-app-1 admsys-prod-app-2 admsys-prod-app-3 admsys-prod-app-4 admsys-prod-app-5 admsys-prod-app-6 atlas-prod-app-1 atlas-prod-app-2 atlas-prod-app-3 atlas-prod-app-4 finsys-prod-app-1 finsys-prod-app-2 finsys-test-app-1 finsys-test-app-2 esapis-test-app-1 esapis-test-app-2 esapis-qa-app-1 esapis-dev-app-1 stusys-test-app-1 stusys-test-app-2 stusys-test-app-3 stusys-test-app-4
do

echo $node;
#ssh root@$node 'ls -la /usr/local/tomcat00*/webapps/*.war';
#ssh root@$node 'grep factory /usr/local/tomcat00*/conf/context.xml';
ssh root@$node 'grep dev.test /var/local/etc/*/*.properties';
done
