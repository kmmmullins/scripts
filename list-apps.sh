#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
for app in `cat sea-app-10.1.2.txt ` 
do
echo $app;
#echo "DDDate : `date +%F`"
ssh oastest@sea-app-1 "/oracle/ora_app/test_app02/bin/dcmctl listapplications -co $app"
echo "---------------"
done
