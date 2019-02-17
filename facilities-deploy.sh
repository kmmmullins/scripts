#!/bin/bash

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


REMOTENODE=admsys-dev-app-1
REMOTETOMCAT=tomcat002
REMOTEDIRBASE=/usr/local
REMOTEWEBAPPS=webapps
REMOTEWAR=apps#facilities.war
LOCALDIRBASE=/usr/local
LOCALTOMCAT=tomcat002
LOCALWEBAPPS=webapps
LOCALFILE=/usr/local/tomcat002/webapps/apps#facilities.war



KERBSTATUS=`klist 2>/dev/null | grep Default | wc -l`
#echo "$KERBSTATUS"


if [ $KERBSTATUS -lt 1 ]

then
 
  printf "\t\t*** Please kinit as your non-root user and try again \n"
  exit
              else
         KERBNAME=`klist 2>/dev/null | grep Default | awk '{print $3}' | awk -F"@" '{print $1}'`

         printf "\n                          \n"
         printf "Authenticating via $KERBNAME \n"
         printf "\n                          \n"
#         printf "+-------------------------------------------------------------------------------------+\n\n"
fi


scp root@${REMOTENODE}:/${REMOTEDIRBASE}/${REMOTETOMCAT}/${REMOTEWEBAPPS}/${REMOTEWAR} ${LOCALDIRBASE}/${LOCALTOMCAT}/${LOCALWEBAPPS}


if [[ -e ${LOCALFILE} ]]  
then
  echo "In found file with ${LOCALFILE} "
  else
  echo "NO -e"
fi







