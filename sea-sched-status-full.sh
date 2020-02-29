#!/bin/bash 
#

for node in sea-sched-1 sea-sched-3
do
echo "********************************"
echo $node;


ssh oastest@$node '/oracle/product/10gR2/opmn/bin/opmnctl status '

ssh oastest@$node '/oracle/product/forms/opmn/bin/opmnctl status '


ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl status '

done

for node in sea-sched-2 sea-sched-4
do
echo "********************************"
echo $node;


ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl status'
done



