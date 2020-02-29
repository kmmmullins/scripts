#/bin/sh
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

#
# Execute tms_to datafeed and move file from Mitsis to sky-works-3
#
#
#
/home/datafeed/bin/dfeed.pl acs-athletics  


#
# Check is datafeed moved the file

LOCALFILEDIR=/home/datafeed/feeds/acs-athletics/archive/
LOCALFILE=`ls -r /home/datafeed/feeds/acs-athletics/archive/MIT2ACSAthletics*.csv | tail -1`

if [[ -f $LOCALFILE ]]
then

LFILE=${LOCALFILE##*/}
RMTACCOUNT=apiMITBeta@files.acsathletics.com
RMTFILE=$LFILE
PASSWORD=apiMITBeta889

#
# Move the file to remote host
#

cd $LOCALFILEDIR

/home/datafeed/adhoc/acs-athletics-to-sftp.sh "$RMTACCOUNT" "$RMTFILE"

echo $?

fi
#
#
echo "Finished"
