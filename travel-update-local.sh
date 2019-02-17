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
#FILELOC=$p
#FPATH=${FILELOC%/*}
#FFILE=${FILELOC##*/}
#FBASE=${FFILE%%.*}
#FEXT=${FFILE#*.}


REMOTENODE=earth-app-21
REMOTEDIRBASE=/home/informit/htdocs/epr
#LOCALDIRBASE=/home/informit
LOCALHTMLFILE=/home/informit/htdocs/epr/3.1travel_risk.html
LOCALPDFFILE=/home/informit/htdocs/epr/downloads/
#LOCALBASE=/home/kmullins/informit
LOCALBASEEPR=/home/kmullins/informit/htdocs/epr
LOCALBASEDOWNLOADS=/home/kmullins/informit/htdocs/epr/downloads
LOCALBASEHTMLFILE=/home/kmullins/informit/htdocs/epr/3.1travel_risk.html
#LOCALBASEARCHIVE=/home/kmullins/informit/archive
#TESTNODES="sea-app-21 sea-app-22"
#PRODNODES="sky-app-21 sky-app-22"
REMOTETIER=$1

case ${REMOTETIER} in
  test)  REMOTENODENAME="sea-app-21 sea-app-22" ;;
  prod)  REMOTENODENAME="sky-app-21 sky-app-22" ;;
  *) echo " unrecognized tier name test or prod " exit 1 ;;
esac

# echo ${REMOTENODENAME}

####################
#
#  Validate Kerb
#
###################


KERBSTATUS=`klist 2>/dev/null | grep Default | wc -l`
if [ $KERBSTATUS -lt 1 ]
then
 
  printf "\t\t*** Please kinit as your root user and try again \n"
  exit
              else

         KERBNAME=`klist 2>/dev/null | grep Default | awk '{print $3}' | awk -F"@" '{print $1}'`
         printf "\n                          \n"
         printf "Authenticating via $KERBNAME \n"
         printf "\n                          \n"
fi



####################
#
# Get 3.1travelrisk
#
###################

travelhtml=`ssh root@earth-app-21 "ls -lart /home/informit/htdocs/epr/ | tail -2 | grep -v drwx" | awk '{print $9}'`
if [ $? -eq 0 ]
      then
        printf "[ In travelhtml]\n"

         printf "\n Remotenode ${REMOTENODE} file ${LOCALBASEEPR} \n"
         scp root@${REMOTENODE}:/${LOCALHTMLFILE}  ${LOCALBASEEPR} 
      else
         printf "\n                          \n"
         printf "[Problem with scp of ${LOCALBASEHTMLFILE}] \n"
         printf "\n                          \n"
         exit 7
      fi

####################
#
# Get pdf
#
###################

travelpdf=`ssh root@earth-app-21 "ls -lart /home/informit/htdocs/epr/downloads/ | tail -2 | grep -v drwx" | awk '{print $9}'`
if [ $? -eq 0 ]
      then
        printf "\n Remotenode ${REMOTENODE} file ${LOCALBASEDOWNLOADS}${travelpdf} \n"
        scp root@${REMOTENODE}:/${LOCALPDFFILE}/${travelpdf} ${LOCALBASEDOWNLOADS}/${travelpdf} 
      else
         printf "\n                          \n"
         printf "[Problem with ${LOCALBASEDOWNLOADS} scp\n"
         printf "\n                          \n"
         exit 7
      fi

         printf "\n                          \n"
         printf "[Local ${LOCALBASEEPR} file] \n"
         ls -la ${LOCALBASEHTMLFILE}
         printf "\n                          \n"
         printf "[Local ${LOCALBASEDOWNLOADS} file] \n"
         ls -la  ${LOCALBASEDOWNLOADS}/${travelpdf}


###################################
#
# Move files to test or production
#
###################################

for rnode in  ${REMOTENODENAME} ;
do
echo " $rnode .....";
       scp ${LOCALBASEHTMLFILE} root@${rnode}:/${LOCALHTMLFILE}
       scp ${LOCALBASEDOWNLOADS}/${travelpdf}   root@${rnode}:/${LOCALPDFFILE}/${travelpdf} 
#       ssh root@${rnode} " hostname; ls -la ${LOCALHTMLFILE}"
#       ssh root@${rnode}  " hostname; ls -la ${LOCALPDFFILE}/${travelpdf} "
done


