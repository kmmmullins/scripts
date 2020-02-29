#! /bin/bash 
#--------------------------------------------------------------------------------------------------#
# File: ua-processed-symlinks.sh                                                                   #
# Auth: Kevin Mullins                                                                              #
# Date: 07/14/14                                                                      #
# Desc:                   #
#--------------------------------------------------------------------------------------------------#
linenum=0;


ITERATIONS="-100"
DATE=`date +%m%d%y%H%M%S`
DATEFMT="%H:%M:%S %m/%d/%Y"
DATEFMTLOG=`date +"${DATEFMT}"`
LOGFILE=/mnt/ua-shared/appComponent/processed/symlink-data/symlink2014.log
DATADIR=/mnt/ua-shared/appComponent/processed/symlink-data/
OLDESTFILES=`ls -lat /mnt/ua-shared/appComponent/processed | tail ${ITERATIONS}  | awk '{print $9}'`
PROCESSDIR=/mnt/ua-shared/appComponent/processed
SUBDIR=/mnt/ua-shared/appComponent/processed/processed-extention
BEGINDIRNUM=`ls -lat /mnt/ua-shared/appComponent/processed | grep -v lrwxrw | wc | awk '{print $1}'`
BEGINLINKNUM=`ls -lat /mnt/ua-shared/appComponent/processed | grep lrwxrw | wc | awk '{print $1}'`
APPCOMPDIR=`ls -la /mnt/ua-shared/appComponent | grep processed | awk '{print $2}'`


      cd ${PROCESSDIR}
      pwd

echo "----"
#for i in "${OLDESTFILES[@]}"
for i in `ls -lat /mnt/ua-shared/appComponent/processed | tail ${ITERATIONS} | awk '{print $9}'`
do

echo " $i ...."

if  [  -d $i ]

 then

    mv $i ${SUBDIR} 
    ln -s ${SUBDIR}/$i $i
    ls -la $i



 else
    echo " $i is a link and not a directory "
 fi


echo "  "

done
echo "+++"

ENDDIRNUM=`ls -lat /mnt/ua-shared/appComponent/processed | grep -v lrwxrw | wc | awk '{print $1}'`
ENDLINKNUM=`ls -lat /mnt/ua-shared/appComponent/processed | grep  lrwxrw | wc | awk '{print $1}'`
echo "The number of subdirecties when started is ${BEGINDIRNUM} , and at the end was ${ENDDIRNUM}"
echo "The number of symbolic links when started is ${BEGINLINKNUM} , and at the end was ${ENDLINKNUM}"
echo "appcompdir ...  ${APPCOMPDIR} "
