#!/bin/bash 
#
#    ua-processed-move.sh    Kevin Mullins
#

linenum=0;
SUBDIR=/home/kmullins/processed/pmmove

for n in `cat /home/kmullins/processed/move-list.txt`

do
#echo "$n" 
linenum=`expr $linenum + 1`
#echo $linenum;

DIRR=/home/kmullins/processed/$n
LINKEDDIR=$SUBDIR/$n

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
           echo " $LINKEDDIR will be moved" >> /home/kmullins/processed-movedtoarchive.txt
         else
            echo " link but not dir for $LINKEDDIR"
        fi
 else
 if [ -d $DIRR ] 
   then
      echo " File $DIRR is a Directory  - will mv $DIRR to archive directory"
      echo " $DIRR will be moved" >> /home/kmullins/processed-movedtoarchive.txt
   else
      if [ -e $DIRR ] 
      then
          echo "regular file $DIRR"
      else
      echo "Directory $DIRR does not exist"
      echo "$DIRR does not exist" >> /home/kmullins/processed-does-not-exist.txt
      fi
   fi
fi

###mv $ddirr /mnt/ua-shared/appComponent/archive/archive_2012/

done

