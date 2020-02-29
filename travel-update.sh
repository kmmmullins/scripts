#!/bin/bash
#
# travel-update - Kevin Mullins
#

DATE=`date +%m%d%y`
#echo $DATE
DATEFMT="%H:%M:%S %m/%d/%Y"
p=`pwd`
d=`dirname $p`
app=`basename $p`
wappdir=`basename $d`
FILELOC=$p
FPATH=${FILELOC%/*}
FFILE=${FILELOC##*/}
FBASE=${FFILE%%.*}
FEXT=${FFILE#*.}


REMOTENODE=earth-app-21
REMOTEDIRBASE=/home/informit/htdocs/epr
LOCALDIRBASE=/home/informit
LOCALHTMLFILE=/home/informit/htdocs/epr/3.1travel_risk.html
LOCALPDFFILE=/home/informit/htdocs/epr/downloads/



KERBSTATUS=`klist 2>/dev/null | grep Default | wc -l`
#echo "$KERBSTATUS"


if [ $KERBSTATUS -lt 1 ]

then
 
  printf "\t\t*** Please kinit as your root user and try again \n"
  exit
              else
         KERBNAME=`klist 2>/dev/null | grep Default | awk '{print $3}' | awk -F"@" '{print $1}'`

         printf "\n                          \n"
         printf "Authenticating via $KERBNAME \n"
         printf "\n                          \n"
#         printf "+-------------------------------------------------------------------------------------+\n\n"
fi


travelhtml=`ssh root@earth-app-21 "ls -lart /home/informit/htdocs/epr/ | tail -2 | grep -v drwx" | awk '{print $9}'`
if [ $? -eq 0 ]
      then
        printf "[ In travelhtml]\n"



         printf "\n Remotenode ${REMOTENODE} file ${LOCALHTMLFILE} \n"
       scp root@${REMOTENODE}:/${LOCALHTMLFILE}  ${LOCALHTMLFILE} 




      else
         printf "\n                          \n"
         printf "[Problem with scp of ${LOCALHTMLFILE}] \n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
      fi


travelpdf=`ssh root@earth-app-21 "ls -lart /home/informit/htdocs/epr/downloads/ | tail -2 | grep -v drwx" | awk '{print $9}'`
if [ $? -eq 0 ]
      then
        printf "[ In travelpdf]\n"
        printf "\n Remotenode ${REMOTENODE} file ${LOCALPDFFILE}${travelpdf} \n"
        scp root@${REMOTENODE}:/${LOCALPDFFILE}/${travelpdf} ${LOCALPDFFILE}${travelpdf} 
   
      else
         printf "\n                          \n"
         printf "[Problem with ${LOCALPDFFILE} scp\n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
      fi

         printf "\n                          \n"
         printf "[Local ${LOCALHTMLFILE} file] \n"
         printf "\n                          \n"
         ls -la ${LOCALHTMLFILE}


         printf "\n                          \n"
         printf "[Local ${LOCALPDFFILE} file] \n"
         printf "\n                          \n"
         ls -la ${LOCALPDFFILE}${travelpdf}




