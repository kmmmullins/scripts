#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
for node in kmmc7.dipr.partners.org kmmc8.partners.org kmmt1.dipr.partners.org 
do
echo $node;
ssh root@$node 'uptime';
done
