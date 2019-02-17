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
     
    for node in sky-app-5 sky-app-6  
    do
    echo $node;
    ssh root@$node "top -b -n1 | grep load "    
    echo "  "
    ssh root@$node "grep agreement /var/log/httpd/registration-secure_access_log | grep POST | wc" 
    ssh root@$node "grep submit_registration /var/log/httpd/registration-secure_access_log | grep POST | wc" 

    echo "  "    
    done

sleep 180

done

