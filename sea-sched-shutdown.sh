#!/bin/bash 
#

for node in sea-sched-1 sea-sched-3
do
echo "********************************"
echo $node;

ssh oastest@$node '/oracle/product/10gR2/opmn/bin/opmnctl shutdown '
if [ $? -gt 0 ]; then
    echo " "
    echo "oastest 10.1.2 - Forms on $node is down"
    echo " "
else

    echo " "
    echo "oastest 10.1.2 - Forms on $node is UP and AVAILABLE"
    echo " "
fi

ssh oastest@$node '/oracle/product/forms/opmn/bin/opmnctl shutdown '
if [ $? -gt 0 ]; then
    echo " "
    echo "oastest 10.1.2 - apps on $node are down"
    echo " "
else

    echo " "
    echo "oastest 10.1.2 - apps on $node are UP and AVAILABLE"
    echo " "
fi


ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl shutdown '
if [ $? -gt 0 ]; then
    echo " "
    echo "Oracle 10.1.3 - apps on $node are down"
    echo " "
else

    echo " "
    echo "Oracle 10.1.3 - apps on $node is UP and AVAILABLE"
    echo " "
fi

echo " ***************************"
done

for node in sea-sched-2 sea-sched-4
do
echo "********************************"
echo $node;


ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl shutdown'
if [ $? -gt 0 ]; then
    echo " "
    echo "Oracle 10.1.3 - apps on $node are down"
    echo " "
else

    echo " "
    echo "Oracle 10.1.3 - apps on $node are UP and AVAILABLE"
    echo " "


fi
done



