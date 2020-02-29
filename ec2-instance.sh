#!/bin/bash
LOCAL_HOSTNAME=$(hostname -d)
if [[ ${LOCAL_HOSTNAME} =~ .*\.amazonaws\.com ]]
then
    echo "This is an EC2 instance"
else
    echo "This is not an EC2 instance, or a reverse-customized one"
fi

if [ -f /sys/hypervisor/uuid ] && [ `head -c 3 /sys/hypervisor/uuid` == ec2 ]; then
     echo yes
else
     echo no
fi
