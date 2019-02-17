#!/bin/bash
#
for node in earth-app-2
do
echo "********************************"
echo $node;
echo "Three instances ...."

ssh oas@$node '/opt/oracle/oraApp/app01/bin/opmnctl status | grep Instance';
if [ $? -gt 0 ]; then
    echo " "
    echo "OASDEV 10.1.2 - Forms on $node is down"
    echo " "
fi
ssh oas@$node '/opt/oracle/oraApp/app02/bin/opmnctl status | grep Instance';
if [ $? -gt 0 ]; then
    echo " "
    echo "OASDEV 10.1.2 - apps on $node are down"
    echo " "
fi
ssh oracle@$node '/home/oracle/product/10.1.3/opmn/bin/opmnctl status | grep Instance';
if [ $? -gt 0 ]; then
    echo " "
    echo "Oracle 10.1.3 - apps on $node are down"
    echo " "
fi
done

echo " ***************************"

for node in earth-sched-1
do
echo $node;
ssh oasdev@$node '/oracle/product/10gR2/bin/opmnctl status | grep Instance';
if [ $? -gt 0 ]; then
    echo " "
    echo "OASDEV 10.1.2 - apps on $node is down"
    echo " "
fi
ssh oasdev@$node '/oracle/product/forms/bin/opmnctl status | grep Instance';
if [ $? -gt 0 ]; then
    echo " "
    echo "OASDEV 10.1.2 - Forms on $node is down"
    echo " "
fi
ssh oracle@$node '/oracle/product/10.1.3/opmn/bin/opmnctl status | grep Instance';
if [ $? -gt 0 ]; then
    echo " "
    echo "Oracle 10.1.3 apps on $node is down"
    echo " "
fi
done
echo " ***************************"

echo "earth-app-3"
ssh oracle@earth-app-3 '/oracle/product/10.1.3/opmn/bin/opmnctl status | grep Instance';
if [ $? -gt 0 ]; then
    echo " "
    echo "Oracle 10.1.3 apps on $node is down"
    echo " "
fi

echo " ***************************"
echo "earth-sched-2"
ssh oracle@earth-sched-2 '/oracle/product/10.1.3.1/bin/opmnctl status | grep Instance';

if [ $? -gt 0 ]; then
    echo " "
    echo "Oracle 10.1.3 apps on $node is down"
    echo " "
fi









