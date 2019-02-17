#!/bin/bash 
#
for node in sea-app-1 sea-app-2 sea-app-3 
do
echo "********************************"
echo $node
ssh oastest@node '/oracle/ora_app/test_app/opmn/bin/opmnctl shutdown  ' 

ssh oastest@$node '/oracle/ora_app/test_app02/opmn/bin/opmnctl shutdown '

ssh oracle@$node '/home/oracle/product/10.1.3/opmn/bin/opmnctl shutdown ' 

done


for node in sea-app-5 sea-app-6
do
echo $node

ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl shutdown ' 


done

. /home/kmullins/scripts/sea-app-status.sh

