#! /bin/bash 
#--------------------------------------------------------------------------------------------------#
# File: ua-processed-symlinks.sh                                                                   #
# Auth: Kevin Mullins                                                                              #
# Date: 07/14/14                                                                      #
# Desc:                   #
#--------------------------------------------------------------------------------------------------#
linenum=0;


ITERATIONS="-10"
DATE=`date +%m%d%y%H%M%S`
DATEFMT="%H:%M:%S %m/%d/%Y"
DATEFMTLOG=`date +"${DATEFMT}"`
#LOGFILE=/mnt/ua-shared/appComponent/processed/symlink-data/symlink2014.log
DATADIR=/mnt/ua-shared/appComponent/processed/symlink-data/
OLDESTFILES=`ls -lat /mnt/ua-shared/appComponent/processed-extention-2014 | tail ${ITERATIONS}  | awk '{print $9}'`
PROCESSDIR=/home/kmullins/tmp
SUBDIR=/mnt/ua-shared/appComponent/processed/processed-extention
PROCESSEXT=/mnt/ua-shared/appComponent/processed-extention-2014
BEGINDIRNUM=`ls -lat /mnt/ua-shared/appComponent/processed | grep -v lrwxrw | wc | awk '{print $1}'`
BEGINLINKNUM=`ls -lat /mnt/ua-shared/appComponent/processed | grep lrwxrw | wc | awk '{print $1}'`
APPCOMPDIR=`ls -la /mnt/ua-shared/appComponent | grep processed | awk '{print $2}'`
#      cd ${PROCESSDIR}
#      pwd

echo "----"
for i in `cat  /home/kmullins/tmp/indexfile.txt`
do

echo " $i ...."

cd ${PROCESSDIR}

if  [  -L $i ]
 then


   echo " $i is a link  "
   ### need to remove link ####

LINKVALUE=`readlink $i`
echo  $LINKVALUE


LPATH=${LINKVALUE%/*}
echo $LPATH
if [ $LPATH == "/home/kmullins/temp" ]
then
   echo "in temp"
else

if [ $LPATH == "/home/kmullins/tmp/archive" ]
then

  echo "in tmp"
else
  echo "bad link"
   echo "NOOOO"
fi
fi






 else
     "$i is not a link"
  fi

done
