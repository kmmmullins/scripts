#!/bin/bash

export SEARCHDIR=/home/kmullins/Documents
FILELOC=""

Form_Name=$1


  export FILELOC=`find ${SEARCHDIR} -iname $Form_Name`

      if [[ $FILELOC ]]
      then
        printf "[ $FILELOC is a valid file]\n"

FPATH=${FILELOC%/*}
FFILE=${FILELOC##*/}
FBASE=${FFILE%%.*}
FEXT=${FFILE#*.}
#NEWFEXT="fmx"
#MODBASE="${FBASE}.${NEWFEXT}"
#COMPILEDFORMNAME="${FPATH}/${MODBASE}"

#echo "ffile = $FFILE "
echo "$FPATH"
#echo "$FBASE "
#echo "$FEXT"
#echo "$MODBASE"
#echo "renamed file $COMPILEDFORMNAME"

#ls -la $COMPILEDFORMNAME






      else
         printf "\n                          \n"
         printf "[$FILELOC Not a valid mitsis form]\n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
      fi



 # echo "************** $FILELOC ****************"
#  ls -la $FILELOC
