#/bin/sh
#-------------------------------------------------------------------------------
# Project               : Databank Files Transfer 
# Platform - OS         : Linux
# Platform - H/W        : HP
# Physical File         : databank-to.sh  
# Created by            : kmm 
# Creation date         : 08/2014     
# File Version          : 0.1
# Program Description :
#-------------------------------------------------------------------------------
# Description : This script will pick up a .cvs file from edis-dev-fs-1 via the databank-to.ctl datafeed
#               and copy the file to sea-fee and sftp the file to Databank. Next we
#               rename the file on sea-feed to indicate that the file was
#               processed
#
#*****************************************************************************
#

#  Variable Initialization
#
DATE_TIME=`date +'%Y-%m-%d %R'`
DATE=`date +%m%d%y%H%M`
KEY=/home/datafeed/keys/df-rsa

LOCALFILEDIR=/home/datafeed/feeds/databank-to/local/
RMTACCOUNT=MITAdmin@sftp1.databankimx.com
PASSWORD=Y1NVUZm6
RMTFILE=*.cvs

# Run databank-to datafeed to get file

   /home/datafeed/bin/dfeed.pl databank-to


if [[ $? -eq 0 ]]
then 

   LOCALFILE=`ls -r /home/datafeed/feeds/databank-to/local/DATABANK_PROSPECT_EXTRACT_??-??-??-??-??.csv`

   if [[ -f $LOCALFILE ]]
   then

      cd $LOCALFILEDIR
      ###  /home/datafeed/adhoc/databank-to-sftp.sh "$RMTACCOUNT" "$RMTFILE"

   else
        echo " "
        echo "Error with file in local directory"
        echo " "
   fi

else
     echo " "
     echo "Error with databank-to datafeed"
     echo " "
fi

#
# Cleanup


echo " localfile ... ${LOCALFILE}"

scp $LOCALFILE oradev@sea-app-11:/home/oracle/datafeeds/outgoing/archive


echo "Going to Remote Host"
#
# Move the file to remote hostecho "Going to Remote Host"
#

cd $LOCALFILEDIR
###/home/datafeed/adhoc/databank-to-sftp.sh "$RMTACCOUNT" "$RMTFILE"

echo "Finished"
