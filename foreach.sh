ZIPFILES=`ls -la /home/kmullins/tmp/test*.txt | awk '{print $9}'`

for EACHFILE in ${ZIPFILES}
do

printf " ${EACHFILE} \n"

LPATH=${EACHFILE%/*}
UPPATH=${LPATH###*/}
LFILE=${EACHFILE##*/}
LBASE=${LFILE%%.*}
LEXT=${LFILE#*.}
MODBASE="$LFILE-processed"
MODFILE=${MODBASE}${LEXT}

echo "--- $UPPATH  ---"
echo $LPATH
echo "$EACHFILE"
echo "base is ..... $LBASE "
echo "lfile = $LFILE "
echo "$LEXT"

#ls -la $EACHFILE
done


