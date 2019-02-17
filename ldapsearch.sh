#! /bin/bash 
#--------------------------------------------------------------------------------------------------#
# File: ldapseearch.sh                                                                             #
# Auth: Kevin Mullins                                                                              #
# Date: 08/10/10                                                                                   #
# Desc: Script to lookup users in ldap                                                             #
#--------------------------------------------------------------------------------------------------#
# Syntax: ldapsearch {username} {tier}                                                             #
#                                                                                                  #
#             ...where...                                                                          #
#                                                                                                  #
#         copy_type      = push|pull                                                               # 
#         remote_host    = name|ip_address                                                         #
#         remote_account = name of the account used to access (ssh) the data directories           # 
#         keyfile        = full path to the public keyfile on the host running smartsync           #
#         source_dir     = full path to the source data directory                                  #
#         target_dir     = full path to the target data directory                                  #
#                                                                                                  #
#         Note that the "context" for the data transfers is defined from the perspective           #
#         of the local host running smartsync and whether the copy_type is a push or a pull:       #
#            - for a push, the source_dir is local and the target_dir is remote                    #
#            - for a pull  the source_dir is remote and the target_dir local.                      #
#                                                                                                  #
#         (To paraphrase Trotsky "Everything is relative" :-)                                      # 
#                                                                                                  #
#--------------------------------------------------------------------------------------------------#
# Status Codes:                                                                                    #
#               0 - Completed                                                                      #
#               1 - Missing command option(s)                                                      #
#               2 - Too many command option(s)                                                     #
#               3 - Invalid hostname specified                                                     #
#               4 - Host not responding                                                            #
#               5 - Remote account not reachable                                                   #
#               6 - Invalid keyfile specified                                                      #
#               7 - Invalid source directory specified                                             #
#               8 - Invalid target directory specified                                             #
#               9 - Invalid copy type specified                                                    #
#--------------------------------------------------------------------------------------------------#
# Hist:                                                                                            #
#       MH - 2010-07-nn: Initial prototype                                                         #
#       MH - 2010-07-nn: Initial prototype                                                         #
#       MH - 2010-08-nn: Added disk space checks before transferring files                         # 
#--------------------------------------------------------------------------------------------------#

#
# Basic necessities:
#
Local_Host=`uname -n`

# 
# Command line specified options
#
Copy_Type=""
Copy_Type=$1
Remote_Host=""
Remote_Host=$2
Remote_Account=""
Remote_Account=$3
Key_File=""
Key_File=$4
Source_Dir=""
Source_Dir=$5
Target_Dir=""
Target_Dir=$6

#
# Function to display correct syntax
#
function print_usage() 
{
   printf "\n"
   printf "Usage: smartsync {copy_type} {remote_host} {remote_account} {keyfile} {source_dir} {target_dir}\n\n" 
   printf "             ...where...\n\n"
   printf "       copy_type      = push|pull\n"
   printf "       remote_host    = name|ip_address\n"
   printf "       remote_account = name of the account used to access (ssh) the data directories\n"
   printf "       keyfile        = full path to the public keyfile on the host running smartsync\n"
   printf "       source_dir     = full path to the source data directory\n"
   printf "       target_dir     = full path to the target data directory\n\n"
   printf "       Note that the "context" for the data transfers is defined from the perspective\n"
   printf "       of the local host running smartsync and whether the copy_type is a push or a pull:\n"
   printf "          - for a push, the source_dir is local and the target_dir is remote\n"
   printf "          - for a pull  the source_dir is remote and the target_dir local.\n\n"
   printf "\n"
   printf "  Example1 - to push files from a local host to a remote host:\n\n"
   printf "    smartsync push rhost.mit.edu remoteuser /home/localhost/keyfile /home/localhost/datadir/ /home/remotehost/datadir/\n\n"
   printf "  Example2 - to pull files from a remote host to a local host:\n\n"  
   printf "    smartsync pull rhost.mit.edu remoteuser /home/localhost/keyfile /home/remotehost/datadir/ /home/localhost/datadir/\n\n"
   printf "\t\t*** Skipping file transfers for this time period***\n\n"  
}

printf "\n+-------------------------------------------------------------------------------------+\n"
printf "                          *** `/bin/date` ***\n\n" 

#
# Verify correct number of command line options have been specified 
#
if [ $# -lt 6 ]
then
   printf "\t\t*** Error - one or more command line options are missing ***\n"
   print_usage
   exit 1 
elif [ $# -gt 6 ]
then
    printf "\t\t*** Error - too many command line options ('$#') specified ***\n"
    print_usage
    exit 2 
fi

#
# Verify copy type is specified correctly:
#
if [ ${Copy_Type} != "push" ] && [ ${Copy_Type} != "pull" ]
then
   printf "\t\t*** Error - invalid copy type ('${Copy_Type}') specified ***\n"
   print_usage
   exit 9
fi

#
# Display options specified:
#
printf "\tThe following options have been specified:\n"
printf "\t\tCopy Type:\t${Copy_Type}\n"
printf "\t\tRemote Host:\t${Remote_Host}\n"
printf "\t\tRemote Account:\t${Remote_Account}\n"
printf "\t\tKey File:\t${Key_File}\n"
printf "\t\tData Source:\t${Source_Dir}\n"
printf "\t\tData Target:\t${Target_Dir}\n"

# 
# Verify host availability
#
printf "\n\tVerifying remote host connectivity..."
Host_Status=""
Host_Status=`/bin/ping -c3 ${Remote_Host} > /dev/null 2>&1`
if [ $? -eq 0 ]
then
   printf "[Confirmed]\n"

   #
   # Verify account access 
   #
   printf "\tVerifying remote account............."
   Acct_Status=""
   Acct_Status=`/usr/bin/ssh -o NumberOfPasswordPrompts=0 -i ${Key_File} ${Remote_Account}@${Remote_Host} "uname -n | tr '[:upper:]' '[:lower:]'" > /dev/null 2>&1`
   if [ $? -eq 0 ]
   then
      printf "[Confirmed]\n"
   else
      printf "[Error - account not valid, key file not valid or inaccessible]\n"
      printf "\t\t*** Skipping file sync for this time period***\n\n"  
      exit 5
   fi

   #
   # Verify source dir
   #
   printf "\tVerifying data source................"
   if [ $Copy_Type == "push" ]
   then
      SrcDir_Status=""
      SrcDir_Status=`/bin/ls -lad ${Source_Dir} > /dev/null 2>&1`
      if [ $? -eq 0 ]
      then
         printf "[Confirmed]\n"
      else
         printf "[Error - source directory not found on ${Local_Host}]\n"
         printf "\t\t*** Skipping file sync for this time period***\n\n"  
         exit 7
      fi
    else
      SrcDir_Status=""
      SrcDir_Status=`/usr/bin/ssh -i ${Key_File} ${Remote_Account}@${Remote_Host} "/bin/ls -lad ${Source_Dir}" > /dev/null 2>&1`
      if [ $? -eq 0 ]
      then
         printf "[Confirmed]\n"
      else
         printf "[Error - source directory not found on ${Remote_Host}]\n"
         printf "\t\t*** Skipping file sync for this time period***\n\n"  
         exit 7
      fi
    fi

   #
   # Verify target dir 
   #
   printf "\tVerifying data target................"
   if [ $Copy_Type == "push" ]
   then
      TarDir_Status=""
      TarDir_Status=`/usr/bin/ssh -i ${Key_File} ${Remote_Account}@${Remote_Host} "/bin/ls -lad ${Target_Dir}" > /dev/null 2>&1`
      if [ $? -eq 0 ]
      then
         printf "[Confirmed]\n"
      else
         printf "[Error - target directory not found on ${Remote_Host}]\n"
         printf "\t\t*** Skipping file sync for this time period***\n\n"  
         exit 8
      fi
   else
      TarDir_Status=""
      TarDir_Status=`/bin/ls -lad ${Target_Dir} > /dev/null 2>&1`
      if [ $? -eq 0 ]
      then
         printf "[Confirmed]\n"
      else
         printf "[Error - target directory not found on ${Local_Host}]\n"
         printf "\t\t*** Skipping file sync for this time period***\n\n"  
         exit 8
      fi
   fi

   #
   # If we made it this far - run the sync 
   #
   printf "\nFile transfers started:   `/bin/date`\n\n"

   if [ ${Copy_Type} == "push" ]
   then
      /usr/local/bin/rsync -avOWz --stats --remove-sent-files -e "/usr/bin/ssh -i ${Key_File}" ${Source_Dir} ${Remote_Account}@${Remote_Host}:${Target_Dir} 
   else
      /usr/local/bin/rsync -avOWz --stats --remove-sent-files -e "/usr/bin/ssh -i ${Key_File}" ${Remote_Account}@${Remote_Host}:${Source_Dir} ${Target_Dir}
   fi

   printf "\nFile transfers completed: `/bin/date`\n"

else
   # 
   # Let's investigate further
   #
   #set -x
   Bad_Host=`/bin/ping -c1 ${Remote_Host} > /dev/null 2>&1` 
   printf "Bad Host = ${Bad_Host}\n"
   if [ $Bad_Host ] 
   then
     printf "[Error - Invalid hostname specified\n"
     printf "\t\t*** Skipping file sync for this time period***\n\n"  
     exit 3
   else
     printf "[Error - Network/connectivity issue]\n" 
     printf "\t\t*** Skipping file sync for this time period***\n\n"  
     exit 4
   fi
#set +x
fi

printf "\n                          *** `date` ***\n" 
printf "+-------------------------------------------------------------------------------------+\n\n"
exit 

#--------------------------------------- Fin ---------------------------------------#

#{
# RSYNC COMMAND
#rsync -az -eahfs $SYNC1 --no-whole-file --stats --include-from="$INCLUDE"
#--exclude-from="$EXCLUDE" "$BACKUP_SRC" "$BACKUP_DEST"; STATUS="$?"
# TELL WHETHER THE BACKUP OPERATION WAS SUCCESSFUL OR NOT.
#if [ "$STATUS" = "0" ]
#then
#echo -e "\nBACKUP SUCCESSFUL!\n"
#set SUBJ_STATUS="Successful"
#else
#echo -e "\nBackup FAILED!\n"
#set SUBJ_STATUS="FAILED!"
#fi
#} tee -a "$LOG_NAME"

#FILE_CHK=$(/usr/bin/rsync -avzh --progress --delete-after --stats -e ssh root@firesafe.mit.edu:/home/mheslin/test/ /home/test/data >> /home/test/logs/xfer.log 2>&1)
#if [ $? != 0 ]
#then 
#   printf "\t\tStatus: No file(s) transferred during this interval\n" 
#else
#   printf "\t\tStatus: File(s) transferred\n" 
#fi

NARIES
LDAPSEARCH=$ORACLE_HOME/bin/ldapsearch
LDAPMODIFY=$ORACLE_HOME/bin/ldapmodify
LDAPADD=$ORACLE_HOME/bin/ldapadd
LDAPDELETE=$ORACLE_HOME/bin/ldapdelete
MKPWD=/sis/accounts/.bin/mkpwd
SQLPLUS=$ORACLE_HOME/bin/sqlplus
SENDMAIL=/usr/lib/sendmail

# OID
LDAP_PORT=636
DEV_OID_SERVER=earth-chart.mit.edu
TEST_OID_SERVER=sea-chart.mit.edu
PROD_OID_SERVER=sky-chart.mit.edu


# EMAIL ADDRESSES
MITSIS_ACCOUNT_EMAIL=mitsis-accounts@mit.edu
DBA_TEAM_EMAIL=ssit-iteam@mit.edu

#-------------------------------------------------------------------------------
# Get the server name of the specified server tier.
#
# @param server_tier The OID server tier.
#-------------------------------------------------------------------------------
get_oid_server() {
    function_name="`basename $0`:get_oid_server"
    
    server_tier=$1

    if [ -z "$server_tier" ]; then
        log_error "The OID server tier was not specified" $function_name
    fi

    # Set the tier SID
    case $server_tier in
        earth) oid_server_name="earth-chart.mit.edu";;
        sea) oid_server_name="sea-chart.mit.edu";;
        sky) oid_server_name="sky-chart.mit.edu";;
        *) log_error "The specified tier \"$server_tier\" DOES NOT EXIST" $function_name;
           return 1;;
    esac    
}

A
A
A
A
A
A
A
A

