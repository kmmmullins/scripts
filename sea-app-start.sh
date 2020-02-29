#!/bin/bash 
#
for node in sea-app-1 sea-app-2 sea-app-3; 
do
echo "********************************"
echo $node
ssh oastest@node '/oracle/ora_app/test_app/opmn/bin/opmnctl startall ' 
#ssh oastest@node '/oracle/ora_app/test_app/opmn/bin/opmnctl status ' 

ssh oastest@$node '/oracle/ora_app/test_app02/opmn/bin/opmnctl startall '
#ssh oastest@$node '/oracle/ora_app/test_app02/opmn/bin/opmnctl status '

ssh oracle@$node '/home/oracle/product/10.1.3/opmn/bin/opmnctl startall ' 
#ssh oracle@$node '/home/oracle/product/10.1.3/opmn/bin/opmnctl status ' 

done


for node in sea-app-5 sea-app-6;
do
echo $node

ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl startall ' 
#ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl status ' 


done

. /home/kmullins/scripts/sea-app-status.sh

