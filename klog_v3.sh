#!/bin/bash
#
#  Check for updated hosts file, and import if new
#
#  12/08/07
#  KMM 
#
#

DATE_TIME=`date +'%Y-%m-%d %R'`
DATE=`date +%m%d%y%H%M`


case "$1" in
        mitsis)
echo  "   "
echo  "   "
echo  "   ------------- Mitsis Sky-app-1 Secure Access  --------------"
echo  "   "
ssh root@sky-app-1 'tail -20 /oracle/logs/mitsis/mitsis_access_log'
echo  "   "
echo  "   ------------- Mitsis Sky-app-2 Secure Access  --------------"
echo  "   "
ssh root@sky-app-2 'tail -20 /oracle/logs/mitsis/mitsis_access_log'
echo  "   "
echo  "   ------------- Mitsis Log Locations  --------------"
echo  "   "
echo  "   ### Sky-app-1 Sky-app-2  /oracle/logs/mitsis_access_log ### "
echo  "   "
echo  "   ------------- Mitsis Log Locations   --------------"
echo  "   "
            ;;

        mitsis-error)
echo  "   "
echo  "   "
echo  "   ------------- Mitsis Sky-app-1 Error Log  --------------"
echo  "   "
ssh root@sky-app-1 'tail  /oracle/logs/mitsis/mitsis_error_log'
echo  "   "
echo  "   ------------- Mitsis Sky-app-2 Error Log  --------------"
echo  "   "
ssh root@sky-app-2 'tail  /oracle/logs/mitsis/mitsis_error_log'
echo  "   "
echo  "   ------------- Mitsis Error Log Locations --------------"
echo  "   "
echo  "   Sky-app-1 sky-app-2  /oracle/logs/mitsis_error_log "
echo  "   "
echo  "   ------------- Mitsis Error Log Locations --------------"
echo  "   "
echo  "   "

            ;;

        websis-secure)

echo  "   "
echo  "   "
echo  "   ------------- Websis - Student sky-app-1 secure Log  --------------"
echo  "   "
ssh root@sky-app-1 'tail /oracle/logs/websis/student-secure_access_log' 
echo  "   "
echo  "   ------------- Websis - Student sky-app-2 Secure Log  --------------"
echo  "   "
ssh root@sky-app-2 'tail /oracle/logs/websis/student-secure_access_log' 
echo  "   "
echo  "   "
echo  "   ------------- Websis - Student Secure Log locations  --------------"
echo  "   "
echo  "   Sky-app-1 Sky-app-2  /oracle/logs/websis/student-secure_access_log "
echo  "   "
echo  "   ------------- Websis - Student Secure Log locations  --------------"
echo  "   "
echo  "   "
            ;;
        websis-nonsecure)
echo  "   "
echo  "   "
echo  "   ------------- Websis - Student Non-Secure Log Sky-app-1 --------------"
echo  "   "
ssh root@sky-app-1 'tail /oracle/logs/websis/student-nonsecure_access_log' 
echo  "   "
echo  "   ------------- Websis - Student Non-Secure Log  Sky-app-2 --------------"
echo  "   "
ssh root@sky-app-2 'tail /oracle/logs/websis/student-nonsecure_access_log' 
echo  "   "
echo  "   ------------- Websis - Student Non-Secure Log Locatios --------------"
echo  "   "
echo  "   Sky-app-1 Sky-app-2  /oracle/logs/websis/student-nonsecure_access_log "
echo  "   "
echo  "   ------------- Websis - Student Non-Secure Log Locatios --------------"
echo  "   "
            ;;
        sisapp)
echo  "   "
echo  "   "
echo  "   ------------- Sisapp Secure Log Sky-app-1  --------------"
echo  "   "
ssh root@sky-app-1 'tail -20 /oracle/logs/j2ee/sisapp-secure_access_log' 
echo  "   "
echo  "   ------------- Sisapp Secure Log Sky-app-2  --------------"
echo  "   "
ssh root@sky-app-2 'tail -20 /oracle/logs/j2ee/sisapp-secure_access_log' 
echo  "   "
echo  "   ------------- Sisapp Log Locations --------------"
echo  "   "
echo  "   Sky-app-1 Sky-app-2  /oracle/logs/websis/student-nonsecure_access_log "
echo  "   "
echo  "   ------------- Sisapp Log Locations --------------"
echo  "   "
echo  "   "
            ;;
        work)
echo  "   "
            echo   " in work "
echo  "   "
echo  "   ------------- Local Files --------------"
echo  "   "

echo  "   "
echo  "   ------------ Checking Current files -------------"
echo  "   "

echo  "   "
echo  "   ------------------ Copy Files ------------------- "
echo  "   "

echo  "   "
echo  "   "




            ;;
     *)    



echo "Usage klog.sh mitsis"
echo "Usage klog.sh mitsis-error"
echo "Usage klog.sh websis-secure"
echo "Usage klog.sh websis-nonsecure"



esac


