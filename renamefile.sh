#/bin/sh -xv
#-------------------------------------------------------------------------------
#
#  Variable Initialization
#
DATE_TIME=`date +'%Y-%m-%d %R'`
DATE=`date +%m%d%y%H%M`
#KEY=/home/datafeed/keys/df-rsa

LOCALFILEDIR=/home/kmullins/tmp
LOCALFILE=`ls -lart /home/kmullins/tmp/*.zip | tail -1 | awk '{print $9}'`


echo "$LOCALFILE"


if [[ -f $LOCALFILE ]]
then

LPATH=${LOCALFILE%/*}
UPPATH=${LPATH###*/}
LFILE=${LOCALFILE##*/}
LBASE=${LFILE%%.*}
LEXT=${LFILE#*.}
MODBASE="$LFILE-processed"
MODFILE=${MODBASE}${LEXT}
#RENAMEFILE="${LPATH}/${MODBASE}"
NEWPATH="${LPATH}/archive"
RENAMEFILE="${NEWPATH}/${MODBASE}"

echo "--- $UPPATH  ---"
echo $LPATH
echo "$LOCALFILE"
echo "base is ..... $LBASE "
echo "lfile = $LFILE "
echo "$LEXT"
echo "$MODBASE"
echo "$MODFILE "
echo "$RENAMEFILE"

mv $LOCALFILE $RENAMEFILE
echo  $LOCALFILE $RENAMEFILE
ls -la $RENAMEFILE 


else

echo "File not found"
fi


