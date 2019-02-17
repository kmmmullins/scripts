#/bin/sh
#-------------------------------------------------------------------------------
# Project               : Tuition Management System Transfer FROM 
# Platform - OS         : Linux
# Platform - H/W        : HP
# Physical File         : tms_from-transmit.sh  
# Created by            : kmm 
# Creation date         : 08/2010     
# File Version          : 0.1
# Program Description :
#-------------------------------------------------------------------------------
# Description : This script will pull a pick file from the TMS SFTP site and 
#               drop the file in the tms_from/archive directory. Next the 
#               tms_from datafeed will run and move the file to mitsis.
#
#*****************************************************************************
#

#  Variable Initialization
#
DATE_TIME=`date +'%Y-%m-%d %R'`
DATE=`date +%m%d%y%H%M`
KEY=/home/datafeed/keys/df-rsa

LOCALFILEDIR=/home/datafeed/feeds/tms_from/local/
#RMTACCOUNT=MassInstituteTech@ssh1.afford.com
RMTACCOUNT=MassInstituteTech@ftp.tuitionmanagementsystems.com
RMTFILE=*MassInstTech.txt
RMTFILE2=*_MIT_Buds.xls 
RMTFILE3=*MassInstTech_Grad.txt

# Move to archive directory

cd $LOCALFILEDIR


################################################
#
# Move MassInstTech.txt Files
#
################################################

echo "Going to Remote Host - $RMTFILE"
#
# Move the file to remote host
#
#

sftp $RMTACCOUNT<<ENDOFHERE
cd Outgoing
ls -la
get  $RMTFILE
quit
ENDOFHERE

echo $?

LOCALFILE=`ls -art /home/datafeed/feeds/tms_from/local/*MassInstTech.txt | tail -1`

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

###echo " LPATH=$LPATH - LFILE=$LFILE - LBASE=$LBASE  - MODBASE=$MODBASE - MODFILE=$MODFILE - RENAMEDFILE=$RENAMEDFILE "

mv $LOCALFILE $RENAMEDFILE

ls -la $RENAMEDFILE 

sftp $RMTACCOUNT<<ENDOFHERE
cd Outgoing
ls -la
rm $RMTFILE
quit
ENDOFHERE

else
          echo "File $RMTFILE Not Found in /home/datafeeds/feeds/tms-from/local "
fi

################################################
#
# Now move *Mit_Buds.xls Files
#
################################################

echo "Going to Remote Host - $RMTFILE2"
#
# Move the file to remote host
#
#

sftp $RMTACCOUNT<<ENDOFHERE
cd Outgoing
ls -la
get  $RMTFILE2
quit
ENDOFHERE

echo $?

LOCALFILE2=`ls -art /home/datafeed/feeds/tms_from/local/*MIT_Buds.xls | tail -1`

echo $?

if [[ -f $LOCALFILE2 ]]
then

echo "yesss2"

ls -la $LOCALFILE2 

sftp $RMTACCOUNT<<ENDOFHERE
cd Outgoing
ls -la
rm $RMTFILE2
quit
ENDOFHERE

else
          echo "File $RMTFILE2 Not Found in /home/datafeeds/feeds/tms-from/local"
fi

################################################
#
# Move MassInstTech_Grad.txt Files
#
################################################
##
##echo "Going to Remote Host - $RMTFILE3"
#
# Move the file to remote host
#
#

##sftp $RMTACCOUNT<<ENDOFHERE
##cd Outgoing
##ls -la
##get  $RMTFILE3
##quit
##ENDOFHERE

##echo $?

##LOCALFILE=`ls -art /home/datafeed/feeds/tms_from/local/*MassInstTech_Grad.txt | tail -1`

##echo $?

##if [[ -f $LOCALFILE ]]
##then

##echo "yesss3"

##LPATH=${LOCALFILE%/*}
##LFILE=${LOCALFILE##*/}
##LBASE=${LFILE%%.*}
##LEXT=${LFILE#*.}
##MODBASE="${LBASE}-${DATE}"
##MODFILE="${MODBASE}.${LEXT}"
##RENAMEDFILE="${LPATH}/${MODFILE}"

#################echo " LPATH=$LPATH - LFILE=$LFILE - LBASE=$LBASE  - MODBASE=$MODBASE - MODFILE=$MODFILE - RENAMEDFILE=$RENAMEDFILE "

##mv $LOCALFILE $RENAMEDFILE

##ls -la $RENAMEDFILE 

##sftp $RMTACCOUNT<<ENDOFHERE
##cd Outgoing
##ls -la
##rm $RMTFILE3
##quit
##ENDOFHERE

##else
          echo "File $RMTFILE3 Not Found in /home/datafeeds/feeds/tms-from/local "
##fi
########
#
# Execute tms_from datafeed and move file from skyfeed to Mitsis
#
/home/datafeed/bin/dfeed.pl tms_from 
echo "Finished"



