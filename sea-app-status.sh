#!/bin/bash 
#
for node in sea-app-1 sea-app-2 sea-app-3; 
do
echo "********************************"
echo $node

ssh oastest@$node '/oracle/ora_app/test_app/opmn/bin/opmnctl status | grep Instance'
if [ $? -gt 0 ]; then
    echo " "
    echo "OASDEV 10.1.2 - Forms on $node is down"
    echo " "
else

    echo " "
    echo "OASDEV 10.1.2 - Forms on $node is up and available for use"
    echo " "
fi


#echo $node
ssh oastest@$node '/oracle/ora_app/test_app02/opmn/bin/opmnctl status | grep Instance'
if [ $? -gt 0 ]; then
    echo " "
    echo "OASDEV 10.1.2 - apps on $node are down"
    echo " "
else 

    echo " "
    echo "OASDEV 10.1.2 - apps on $node are up and available for use"
    echo " "


fi

#echo $node;
ssh oracle@$node '/home/oracle/product/10.1.3/opmn/bin/opmnctl status | grep Instance'
if [ $? -gt 0 ]; then
    echo " "
    echo "Oracle 10.1.3 - apps on $node are down"
    echo " "
fi
done

echo " ***************************"


for node in sea-app-5 sea-app-6;
do
echo $node;
ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl status | grep Instance'
if [ $? -gt 0 ]; then
    echo " "
    echo "Oracle 10.1.3 apps on $node is down"
    echo " "
fi
done



for node in sea-sched-1
do
echo "********************************"
echo $node;

ssh oastest@$node '/oracle/product/10gR2/bin/opmnctl status | grep Instance'
if [ $? -gt 0 ]; then
    echo " "
    echo "oastest 10.1.2 - Forms on $node is down"
    echo " "
fi

#echo $node;
ssh oastest@$node '/oracle/product/forms/bin/opmnctl status | grep Instance'
if [ $? -gt 0 ]; then
    echo " "
    echo "oastest 10.1.2 - apps on $node are down"
    echo " "
fi


#echo $node;
ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl status | grep Instance'
if [ $? -gt 0 ]; then
    echo " "
    echo "Oracle 10.1.3 - apps on $node are down"
    echo " "
fi

echo " ***************************"
done

node=sea-sched-2
echo $node;
ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl status | grep Instance'
if [ $? -gt 0 ]; then
    echo " "
    echo "Oracle 10.1.3 - apps on $node are down"
    echo " "
fi
