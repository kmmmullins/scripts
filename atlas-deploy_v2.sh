#!/bin/bash
#
# Atlas Tomcat Deploy - Kevin Mullins
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


REMOTENODE=atlas-dev-app-1
REMOTETOMCAT=tomcat001
REMOTEDIRBASE=/usr/local
REMOTEWEBAPPS=webapps
REMOTEWAR=atlas.war
LOCALDIRBASE=/usr/local
LOCALTOMCAT=tomcat001
LOCALWEBAPPS=webapps
LOCALWAR=atlas.war
LOCALFILE=/usr/local/tomcat001/webapps/atlas.war



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



CURRENTWARFILE=`find ${LOCALDIRBASE}/${LOCALTOMCAT}/${LOCALWEBAPPS} -iname ${LOCALWAR} -ls`



scp root@${REMOTENODE}:/${REMOTEDIRBASE}/${REMOTETOMCAT}/${REMOTEWEBAPPS}/${REMOTEWAR} ${LOCALDIRBASE}/${LOCALTOMCAT}/${LOCALWEBAPPS}

if [ $? -eq 0 ]
      then
        printf "[ In ok]\n"
      else
         printf "\n                          \n"
         printf "[Problem with scp\n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
      fi


if [[ -e ${LOCALFILE} ]]  
then
  echo " Found file ${LOCALFILE} "

  echo " "
  NEWWARFILE=`find ${LOCALDIRBASE}/${LOCALTOMCAT}/${LOCALWEBAPPS} -iname ${LOCALWAR} -ls`

         printf "\n Original War file $CURRENTWARFILE                      \n"
         printf "\n"
#         printf "\n New War file $NEWWARFILE                      \n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"





  echo " "
  ls -la ${LOCALFILE}
  echo " "
  /etc/init.d/tomcat001 stop
  TOMCATDOWN=`ps -ef | grep tomcat001 | grep -v grep`



if [ ${#TOMCATDOWN} -gt 0 ] ; 
then
   echo  "tomcat still running"
   exit
else



#  ps -ef | grep tomcat001 | grep -v grep


# /etc/init.d/tomcat001 start


  else
  echo "NO ${LOCALFILE}"
fi







