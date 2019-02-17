#! /bin/bash 
#--------------------------------------------------------------------------------------------------#
# File: processed-dir-count.sh                                                                   #
# Auth: Kevin Mullins                                                                              #
# Date: 07/14/14                                                                      #
# Desc:                   #
#--------------------------------------------------------------------------------------------------#
linenum=0;


DATE=`date +%m%d%y%H%M%S`
DATEFMT="%H:%M:%S %m/%d/%Y"
DATEFMTLOG=`date +"${DATEFMT}"`
LOGFILE=/mnt/ua-shared/appComponent/processed/symlink-data/symlink2014.log
DATADIR=/mnt/ua-shared/appComponent/processed/symlink-data/
APPCOMPDIR=`ls -la /mnt/ua-shared/appComponent | grep processed | awk '{print $2}'`
OLDESTFILES=`ls -lat /mnt/ua-shared/appComponent/processed | tail -10 | awk '{print $9}'`
PROCESSDIR=/mnt/ua-shared/appComponent/processed
SUBDIR=/mnt/ua-shared/appComponent/processed/processed-extention
BEGINDIRNUM=`ls -lat /mnt/ua-shared/appComponent/processed | grep -v lrwxrw | wc | awk '{print $1}'`
BEGINLINKNUM=`ls -lat /mnt/ua-shared/appComponent/processed | grep lrwxrw | wc | awk '{print $1}'`


echo "appcompdir ...  ${APPCOMPDIR} "



echo "  "


ENDDIRNUM=`ls -lat /mnt/ua-shared/appComponent/processed | grep -v lrwxrw | wc | awk '{print $1}'`
ENDLINKNUM=`ls -lat /mnt/ua-shared/appComponent/processed | grep  lrwxrw | wc | awk '{print $1}'`
echo "The number of subdirecties when started is ${BEGINDIRNUM} , and at the end was ${ENDDIRNUM}"
echo "The number of symbolic links when started is ${BEGINLINKNUM} , and at the end was ${ENDLINKNUM}"



