#!/bin/bash
#
#


for i in `seq 1 1000`;
    do 

NOW=$(date +"%m-%d-%y-%T")
#echo $NOW


    app5cnt=`ssh root@sky-app-5 "grep agreement /var/log/httpd/registration-secure_access_log | grep POST | wc -l"` 
    app5mcnt=`ssh root@sky-app-5 "grep submit_registration /var/log/httpd/registration-secure_access_log | grep POST | wc -l"` 
    app6cnt=`ssh root@sky-app-6 "grep agreement /var/log/httpd/registration-secure_access_log | grep POST | wc -l"` 
    app6mcnt=`ssh root@sky-app-6 "grep submit_registration /var/log/httpd/registration-secure_access_log | grep POST | wc -l"` 


#echo $app5cnt
#echo $app5mcnt
#echo $app6cnt
#echo $app6mcnt

appcnt=`expr $app5cnt + $app6cnt`
appmcnt=`expr $app5mcnt + $app6mcnt`
tcnt=`expr $appcnt + $appmcnt`
#echo $appcnt


echo "$NOW   $app5cnt   $app5mcnt   $app6cnt  $app6mcnt    $tcnt" 
echo "$NOW   $app5cnt   $app5mcnt   $app6cnt  $app6mcnt    $tcnt" >> /home/kmullins/logs/onlinereg-020612.log


sleep 180

done

