#!/bin/bash 
#
for node in sea-app-4; 
do
echo "********************************"
echo $node

ssh oastest@$node '/oracle/ora_app/test_app02/opmn/bin/opmnctl status '
#ssh oastest@$node '/oracle/ora_app/test_app02/opmn/bin/opmnctl shutdown '
#ssh oastest@$node '/oracle/ora_app/test_app02/opmn/bin/opmnctl status '

ssh oracle@$node '/home/oracle/product/10.1.3/opmn/bin/opmnctl status ' 
#ssh oracle@$node '/home/oracle/product/10.1.3/opmn/bin/opmnctl shutdown ' 
#ssh oracle@$node '/home/oracle/product/10.1.3/opmn/bin/opmnctl status ' 

done


for node in sea-app-7;
do
echo $node

##ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl shutdown ' 
ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl status ' 

done

for node in forms-qa-app-3;
do
echo $node

##ssh oracle@$node '/oracle/product/middleware/formshome/bin/opmnctl shutdown ' 
ssh oracle@$node '/oracle/product/middleware/formshome/bin/opmnctl status ' 

done
###. /home/kmullins/scripts/sea-app-status.sh

