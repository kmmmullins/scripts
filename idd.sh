#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#

for i in `seq 1 1000`;

do

    for node in sky-app-21 sky-app-22  
    do
    echo $node;
    ssh root@$node "ps -ef | grep httpd | wc"
    echo "  "    
    done

    sleep 10
done
