#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#

admdev="admsys-dev-app-1 admsys-dev-app-2 earth-app-21 ehs-dev-app-1 events-dev-app-1 atlas-dev-app-1"



for node in $admdev
do
echo $node;

ssh root@$node $@


#echo "DDDate : `date +%F`"
#ssh root@$node "grep ERROR /oracle/logs/ssit-urop_default_island_1/urop.out.log | grep `date +%F`"
echo "---------------"
done
