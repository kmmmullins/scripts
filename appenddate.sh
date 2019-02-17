#!/bin/bash 
#
#
DATE=`date +%m%d%y%H%M%S`
CSVFILE=/home/kmullins/tmp/a.csv
LPATH=${CSVFILE%/*}
LFILE=${CSVFILE##*/}
LBASE=${LFILE%%.*}
LEXT=${LFILE#*.}
MODBASE="$LBASE-$DATE"
MODFILE=${MODBASE}.${LEXT}
NEWPATH="${LPATH}/archive"
RENAMEFILE="${NEWPATH}/${MODFILE}"




  

echo "data ... $DATE"
echo "csvfile ... $CSVFILE"
echo "lpath ... $LPATH"
echo "lfile ... $LFILE"
echo "lbase ... $LBASE"
echo "lext .... $LEXT"
echo "modbase ... $MODBASE"
echo "modfile ... $MODFILE"
echo "newpath ... $NEWPATH"
echo "renamefile ... $RENAMEFILE"


cp $CSVFILE $RENAMEFILE
ls -la $RENAMEFILE



