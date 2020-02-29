#/bin/sh -xv
#-------------------------------------------------------------------------------
# Project               : ACS Athletics  
# Platform - OS         : Linux
# Platform - H/W        : HP
# Physical File         : acs-athletics-transmit-to.sh  
# Created by            : kmm 
# Creation date         : 11/2012     
# File Version          : 0.1
# Program Description :
#-------------------------------------------------------------------------------
# Description : This script will pick up a file from Mitsis via the acs-athletics-to.ctl datafeed
#               and copy the file to sky-feed and sftp the file to acs-athletics 
#
#*****************************************************************************
#

#  Variable Initialization
#
DATE_TIME=`date +'%Y-%m-%d %R'`
DATE=`date +%m%d%y%H%M`
KEY=/home/datafeed/keys/df-rsa
logfile=/home/kmullins/logs/acs.log 
#
# Execute tms_to datafeed and move file from Mitsis to sky-works-3
#
#
#
#/home/datafeed/bin/dfeed.pl acs-athletics  
sstatus=nothing

#
# Check is datafeed moved the file

LOCALFILEDIR=/home/kmullins/Documents/
LOCALFILE=`ls -r /home/kmullins/Documents/upload-this-file.txt | tail -1`

if [[ -f $LOCALFILE ]]
then
echo " in first loop"
   #LFILE=${LOCALFILE##*/}
   RMTACCOUNT=cathie@iteam06.mit.edu
   RMTFILE=$LOCALFILE
   PASSWORD=scooter

#
# Move the file to remote host
#

   cd $LOCALFILEDIR

   /home/kmullins/scripts/acs-athletics-iteam06-sftp.sh "$RMTACCOUNT" "$RMTFILE" >> $logfile 

#echo $?
  
#   kstatus=`tail -9 $logfile | grep -c 100`
#   echo "Status = $kstatus"
#   if [ $kstatus -ne 1 ]
   if [ $? -ne 0 ]

   then

             echo " in second loop failure"
             echo "Problem with transfer to acs-athletics, status of  $kstatus"
##             echo "Transfer had  Problem" | mail -s "Problem with transfer to acs-athletics, status of  $kstatus" kmullins@mit.edu 

   else

             echo " in third  loop successful"
             echo "Found file $LOCALFILE and kstatus = $kstatus"
##             echo "Transfer was Successful" | mail -s "Found file $LOCALFILE and kstatus = $kstatus" kmullins@mit.edu

   fi

else

echo "Could not find file $LOCALFILE"

             echo " in last loop file failure"


fi
#
#
echo "Finished"
