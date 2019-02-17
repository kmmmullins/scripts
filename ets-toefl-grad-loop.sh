#/bin/sh
#-------------------------------------------------------------------------------
# Project               : Tuition Management System Transfer FROM 
# Platform - OS         : Linux
# Platform - H/W        : HP
# Physical File         : ets-toefl-grad.sh  
# Created by            : kmm 
# Creation date         : 08/2010     
# File Version          : 0.1
# Program Description :
#-------------------------------------------------------------------------------
# Description : This script will pull a pick file from the ets-toefl-grad SFTP site and 
#               drop the file in the ets-toefl-grad/archive directory. Next the 
#               ets-toefl-grad datafeed will run and move the file to mitsis.
#
#*****************************************************************************
#

#  Variable Initialization
#
DATE_TIME=`date +'%Y-%m-%d %R'`
DATE=`date +%m%d%y%H%M`

LOCALFILEDIR=/home/datafeed/feeds/ets-toefl-grad/archive/
RMTACCOUNT=ESRDIuser@ets-scorelink.ets.org
PASSWORD=esrETS2011
DATE_TIME=`date +'%Y-%m-%d %R'`
DATE=`date +%m%d%y%H%M`
#KEY=/home/datafeed/keys/df-rsa

LOCALFILEDIR=/home/datafeed/feeds/ets-toefl-grad/archive/
RMTACCOUNT=ESRDIuser@ets-scorelink.ets.org
PASSWORD=esrETS2011
#RMTFILE=TOE35361.*
RMTFILEARRAY=( "TOE35361.*" "TOE35141.*" "TOE35071.*" "TOE35041.*")

for i in  "${RMTFILEARRAY[@]}"

do

echo " some sh script ${RMTACCOUNT} $i "


LOCALFILE=`ls -art /home/datafeed/feeds/ets-toefl-grad/archive/$i`

echo $?

if [[ -f $LOCALFILE ]]
then

echo "yesss"

LPATH=${LOCALFILE%/*}
LFILE=${LOCALFILE##*/}
LBASE=${LFILE%%.*}
LEXT=${LFILE#*.}
MODBASE="${LBASE}-${DATE}"
MODFILE="${MODBASE}.${LEXT}"
RENAMEDFILE="${LPATH}/${MODFILE}"

fi


done



