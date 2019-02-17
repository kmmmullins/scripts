#!/bin/bash

export SEARCHDIR=/home/kmullins/scripts
TAGNAME=$1
STRINGPOS=0
DASHPOS=0
APPDASHES=0



#  export TAGNAME=`find ${SEARCHDIR} -iname $Form_Name`

      if [[ $TAGNAME ]]
      then
        printf "[ $TAGNAME is a valid file]\n"



TAGLEN="${#TAGNAME}"
NUMDASHES=`echo $TAGNAME | grep -o "-" | wc -l`
#echo " Taglen $TAGLEN"
#echo " Dashes $NUMDASHES "
#echo " APPNAME $APPNAME "
DASHES=`expr $NUMDASHES - 1 `

for (( i=0; i<${#TAGNAME}; i++ )); do
#  echo "$i - ${TAGNAME:$i:1} "
  STRINGPOS=`expr $STRINGPOS + 1`
  STRINGVALUE=${TAGNAME:$i:1}
#  echo " stringpos = $STRINGPOS"
#  echo " stringvalue = $STRINGVALUE"

  if [ $STRINGVALUE == "-"  ] 
  then
       APPDASHES=`expr $APPDASHES + 1`
       if [ $APPDASHES == $DASHES ]
       then
           
           echo "stringvalue = $STRINGVALUE and stringpos = $STRINGPOS "
            PULLPOS=`expr $STRINGPOS - 1`     
            echo "pullpos = $PULLPOS" 
           echo " ${TAGNAME:0:$PULLPOS}"
            APPNAME="${TAGNAME:0:$PULLPOS}"      
       fi

  fi




done

      else
         printf "\n                          \n"
         printf "[$TAGNAME Not a valid mitsis form]\n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
      fi



 # echo "************** $TAGNAME ****************"
#  ls -la $TAGNAME
