#!/bin/bash 
#--------------------------------------------------------------------------------------------------#
# File: genwd.sh                                                                                   #
# Auth: Kevin Mullins                                                                              #
# Date: 07/10/13                                                                                   #
# Desc: Script to generate user passwords using kerb and hash                                      #
#--------------------------------------------------------------------------------------------------#
# Syntax: genpw.sh {kerberos ID}                                                                   #
#                                                                                                  #
#--------------------------------------------------------------------------------------------------#
#                                                                                                  #
#-------------------#
# Basic necessities #
#-------------------#
Local_Host=`uname -n`

export ORACLE_HOME=/oracle/product/middleware/forms
export PATH=/oracle/product/middleware/formshome/bin:/oracle/product/middleware/forms/bin:${PATH}
export JAVA_HOME=/oracle/product/middleware/forms/jdk/bin/java


#--------------------------------# 
# Command line specified options #
#--------------------------------# 
Tier=""
Tier=$1
Kerb_Name=""
Kerb_Name=$2
ABORT=0
CASEFLAG=0

export upperkerbname=`echo ${Kerb_Name} | tr '[:lower:]' '[:upper:]'`
export TIERNAME=`echo ${Tier} | tr '[:lower:]' '[:upper:]'`
#------------------------------------#
# Function to display correct syntax #
#------------------------------------#
function print_usage() 
{
   printf "\n"
   printf "Usage: genpw.sh {TIER} {KERB_NAME}  \n\n" 
   printf "Where  {TIER} = PROD, TEST, QA1,  QA2, QA3, QA4, SCHED-DEV, SCHED-TEST1, SCHED-TEST2 or DEV  \n\n" 
}

# Verify correct number of command line options have been specified # 
#-------------------------------------------------------------------#
if [ $# -lt 2 ]
then
   printf "\n"
   printf "\t\t*** Error - Missing command line options ***\n"
   print_usage
   exit 1 
fi

#-------------------------------------------------------------------#
#  Take static feed, add kerb id to end, take a sha1 hash           #
#  and use characters 11-25 for the password                        # 
#-------------------------------------------------------------------#
case "${TIERNAME}" in


PROD) 

export staticPWD="AzWe149kLL750b0sqtdbT0nGkP4s8"
CASEFLAG=1
;;

TEST) 

export staticPWD="AzWe149kLL750b0sqtdbT0nppR2q4"
CASEFLAG=1

;;

DEV)

export staticPWD="AzWe149kLL750b0sqtdbT0nppY27F5"
CASEFLAG=1
;;

QA1)

export staticPWD="AzWe149kLL750b0sqtdbT0n6Gbn8K"
CASEFLAG=1
;;

QA2)

export staticPWD="AzWe149kLL750b0sqtdbT0k4Ro2v"
CASEFLAG=1
;;

QA3)
export staticPWD="AzWe149kLL750b0sqtdbT0nU4syQ9"
CASEFLAG=1
;;

QA4)
export staticPWD="AzWe149kLL750b0sqtdbT0n6Gbn8K"
CASEFLAG=1
;;

SCHED-DEV)
export staticPWD="AzWe149kLL750b0sqtdbT0npTg3i91"
CASEFLAG=1
;;

SCHED-TEST1)
export staticPWD="AzWe149kLL750b0sqtdbT0nRR4g2"
CASEFLAG=1
;;

SCHED-TEST2)
export staticPWD="AzWe149kLL750b0sqtdbT0nF9KL2q"
CASEFLAG=1
;;







*)
   printf " \n"
   printf "Invalid tier name $1 \n"
   printf "Usage: genformspw.sh {TIER} {KERB_NAME}  \n\n" 
   printf "Where  {TIER} = PROD, TEST, QA1,  QA2, QA3, or DEV  \n\n" 
   if [ $CASEFLAG -eq 0 ]
   then 
          export ABORT=1
          exit
   fi

;;
esac


#echo $Kerb_Name
export upperkerbname=`echo ${Kerb_Name} | tr '[:lower:]' '[:upper:]'`
export PWDP=OPS\$
export remoteUser=$PWDP$upperkerbname
#echo "remoteuser ... $remoteUser"
export namelen=${remoteUser}
export n=${remoteUser}
export namelen=${#n}
export username=${n:4:$namelen}
export PWDPREP=$staticPWD$remoteUser
export sha1hash=`echo -n $PWDPREP | sha1sum `
export userpw=${sha1hash:10:15}
#echo ${n} ${username} ${userpw}| tee -a ${userpwd}

printf " \n"
printf "$remoteUser - $1 -  password: $userpw \n"
printf " \n"
printf "alter user \"$remoteUser\" identified by \"$userpw\"; \n"
printf " \n"

