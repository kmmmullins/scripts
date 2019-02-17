#/bin/sh -x
#-------------------------------------------------------------------------------
#
#  Variable Initialization
#
DATE_TIME=`date +'%Y-%m-%d %R'`
DATE=`date +%m%d%y%H%M`
#KEY=/home/datafeed/keys/df-rsa

LOCALFILEDIR=/home/
LOCALFILE=`find /home/kmullins/www/secure/html/misc -iname TASFORM.FMB`


echo "$LOCALFILE"


if [[ -f $LOCALFILE ]]
then

LPATH=${LOCALFILE%/*}
LPATH2=${LPATH%/*}
LFILE=${LOCALFILE##*/}
LFILE2=${LPATH##*/}
LBASE=${LFILE%%.*}
LEXT=${LFILE#*.}
NEWLEXT="fmx"
MODBASE="${LBASE}.${NEWLEXT}"
RENAMEFILE="${LPATH}/${MODBASE}"

echo "lfile = $LFILE "
echo "$LPATH"
echo "$LPATH2"
echo "$LFILE2"
echo "$LBASE "
echo "$LEXT"
echo "$MODBASE"
echo "$RENAMEFILE"

ls -la $RENAMEFILE 


else

echo "File not found"
fi


