#/bin/sh
#-------------------------------------------------------------------------------
# Project               : Tuition Management System Transfer FROM 
# Platform - OS         : Linux
# Platform - H/W        : HP
# Physical File         : databank.sh  
# Created by            : kmm 
# Creation date         : 08/2010     
# File Version          : 0.1
# Program Description :
#-------------------------------------------------------------------------------
# Description : This script will pull a pick file from the databank SFTP site and 
#               drop the file in the databank/archive directory. Next the 
#               ets-sat datafeed will run and move the file to mitsis.
#
#*****************************************************************************
#

#  Variable Initialization
#
DATE_TIME=`date +'%Y-%m-%d %R'`
DATE=`date +%m%d%y%H%M`
KEY=/home/datafeed/keys/df-rsa

LOCALFILEDIR=/home/datafeed/feeds/databank-from/local/
RMTACCOUNT=MITAdmin@sftp1.databankimx.com
PASSWORD=Y1NVUZm6
RMTFILE=*_*.pdf

# Move to archive directory

cd $LOCALFILEDIR


################################################
#
# Move Databank Files
#
################################################

echo "Going to Remote Host"
#
# Move the file to remote host

/home/datafeed/adhoc/databank-from-sftp.sh "$RMTACCOUNT" "$RMTFILE"

echo $?

LOCALFILES=`ls -art /home/datafeed/feeds/databank-from/local/*_*.pdf`

if [[ $? -eq 0 ]]
then

/home/datafeed/bin/dfeed.pl databank-from
echo "ok"


else
          echo " "
          echo "File Not Found in /home/datafeed/feeds/databank-from/local"
          echo " "
fi

echo "Finished"
