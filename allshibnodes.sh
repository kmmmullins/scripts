#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
for node in earth-app-3 sea-app-5 sea-app-6 sea-app-7 stusys-dev-app-1 stusys-qa-app-1 stusys-test-app-1 stusys-test-app-2 websis-dev-app-1 websis-test-app-1 websis-test-app-2 sky-app-5 sky-app-6 stusys-prod-app-1 stusys-prod-app-2 forms-dev-app-1 forms-qa-app-1 forms-qa-app-2 forms-qa-app-3 forms-test-app-1 forms-test-app-2 forms-sched-dev-app-1 forms-sched-test-app-2 forms-sched-test-app-2 forms-prod-app-1 forms-prod-app-2 learning-modules-test-sp gradebook-test-app-1 gradebook-test-app-2 forms-dev-app-1 forms-test-app-1 forms-test-app-2 membership-test-app-1  
do
echo $node;
#ssh root@$node 'grep mit.edu shibboleth2.xml';
ssh root@$node 'grep entityID /etc/shibboleth/shibboleth2.xml  ';
done
