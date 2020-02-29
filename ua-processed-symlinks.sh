#!/bin/bash 
#
#    ua-processed-move.sh    Kevin Mullins
#

linenum=0;
SUBDIR=/d6/ua-shared/appComponent/processed/processed-extention


###  ls -lat /d6/ua-shared/appComponent/processed/ | tail -10 | awk '{print $9}' > /tmp/oldest-dirs-to-process.txt












for n in `cat /home/oraclenfs/ua-processed-files-to-move.txt`

do
#echo "$n" 
linenum=`expr $linenum + 1`
#echo $linenum;

DIRR=/d6/ua-shared/appComponent/processed/$n
LINKEDDIR=$SUBDIR/$n
ARCHIVEDIR=/d6/ua-shared/appComponent/archive/archive_2013



echo "   "
echo " $linenum  $n  ************************************************************"
#echo $DIRR

if  [ -L $DIRR ]
 then
    echo " $DIRR is a link "
#
#   See if the direcory is in subdir
#
         if [ -d $LINKEDDIR ] 
         then
           echo " Found $LINKEDDIR in subdir and will mv from here"
           echo " $LINKEDDIR will be moved" >> /home/oraclenfs/logs/Movedfrom-processed-toarchive-2013.log
           mv $LINKEDDIR $ARCHIVEDIR
              if [ $? -ne 0 ]
              then
               printf "[Error - Moving $LINKEDDIR from subdir ]\n"
               printf "+-------------------------------------------------------------------------------------+\n\n"
               echo " $LINKEDDIR errored moving to the archive directory" >> /home/oraclenfs/logs/Error-log-2013.log
              fi
         else
               echo " link but no dir for $LINKEDDIR"
               echo " $LINKEDDIR link but no directory " >> /home/oraclenfs/logs/Error-log-2013.log
        fi
 else
 if [ -d $DIRR ] 
   then
      echo " File $DIRR is a Directory  - will mv $DIRR to archive directory"
      echo " $DIRR will be moved" >> /home/oraclenfs/logs/Movedfrom-processed-toarchive-2013.log
           mv $DIRR $ARCHIVEDIR
              if [ $? -ne 0 ]
              then
               printf "[Error - Moving $DIRR from processed ]\n"
               printf "+-------------------------------------------------------------------------------------+\n\n"
               echo " $DIRR errored moving to the archive directory" >> /home/oraclenfs/logs/Error-log-2013.log
              fi
   else
      if [ -e $DIRR ] 
      then
          echo "regular file $DIRR"
          echo " $DIRR is a regular file and not a directory" >> /home/oraclenfs/logs/Error-log-2013.log
      else
          echo "Directory $DIRR does not exist"
          echo "$DIRR does not exist" >> /home/oraclenfs/logs/Dirnotfoundinprocessed-2013.log
      fi
   fi
fi

done

