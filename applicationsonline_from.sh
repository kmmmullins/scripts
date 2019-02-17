#/bin/sh
#-------------------------------------------------------------------------------
# Project               : Applicationonline from wrapper script
# Platform - OS         : Linux
# Physical File         : applicationonline_from.sh
# Created by            : kmm 
# Creation date         : 08/08/2104
# File Version          : 0.1
# Program Description :
#-------------------------------------------------------------------------------
# Description : This script will pick execute the applicationonline_from.ctl 
#               file which will pickup files from the applicationonline account
#               on skyfeed and copy with zip file to edis-prod-fs-1. The function
#               of this script is to verify the zip file and then extract the
#               files in the zip on edis-prod-fs-1
#
#*****************************************************************************
#

#  Variable Initialization
DATE_TIME=`date +'%Y-%m-%d %R'`
DATE=`date +%m%d%y%H%M`
KEYFILE=/home/datafeed/keys/datafeed-skyfeed-id_rsa
#
# Execute tms_to datafeed and move file from Mitsis to sky-works-3
#

/home/datafeed/bin/dfeed.pl applicationsonline_from

#
# Check is datafeed moved the file

ZIPFILES=`ssh -i ${KEYFILE} edisprod@edis-prod-fs-1 ls  /home/edisprod/DataRaid/edisprod/ApplicationsOnline/*.zip`

for EACHFILE in ${ZIPFILES}
do

ssh -i ${KEYFILE} edisprod@edis-prod-fs-1 unzip -o ${EACHFILE} -d /home/edisprod/DataRaid/edisprod/ApplicationsOnline/
if [ $? -eq 0 ]
     then
        printf "${EACHFILE} unzipped without issue \n"


      LPATH=${EACHFILE%/*}
      LFILE=${EACHFILE##*/}
      LBASE=${LFILE%%.*}
      LEXT=${LFILE#*.}
      MODBASE="$LFILE-processed"
      MODFILE=${MODBASE}${LEXT}
      NEWPATH="${LPATH}/archive"
      RENAMEFILE="${NEWPATH}/${MODBASE}"
      ssh -i ${KEYFILE} edisprod@edis-prod-fs-1 mv ${EACHFILE} ${RENAMEFILE}
      if [ $? -eq 0 ]
        then
           printf "${EACHFILE} moved to archive directory \n"
        else
           printf "Problem moving ${EACHFILE} to archive directory \n"
           exit 7
        fi

else
         printf "\n                          \n"
         printf "There was a problem unzipping ${EACHFILE}\n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
fi


done
