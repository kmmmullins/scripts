#! /bin/bash 
#--------------------------------------------------------------------------------------------------#
# File: smartsync.sh                                                                               #
# Auth: M. Heslin                                                                                  #
# Date: 07/20/10                                                                                   #
# Desc: Script to transfer files between a remote and local host via rsync.                        #
#       Script can be run from command line but is intended to be run from cron.                   #
#--------------------------------------------------------------------------------------------------#
# Syntax: smartsync {copy_type} {remote_host} {remote_account} {keyfile} {source_dir} {target_dir} #
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
#       MH - 2010-05-18: Proof of concept                                                          #
#       MH - 2010-06-30: Working prototype                                                         #
#       MH - 2010-07-26: Core functionality                                                        #
#       MH - 2010-08-13: Added disk space checks before transferring files                         # 
#       MH - 2010-08-16: Added rsync version check                                                 #
#       MH - 2010-08-18: Added System load and duplicate process checks                            #
#       MH - 2010-09-08: Disabled disk space checks until NFS reporting added in                   # 
#       MH - 2010-09-17: Added --ignore-existing to leave duplicate files in place on source dir   # 
#--------------------------------------------------------------------------------------------------#

#-------------------#
# Basic necessities #
#-------------------#
Local_Host=`uname -n`

#--------------------------------# 
# Command line specified options #
#--------------------------------# 
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

#------------------------------------#
# Function to display correct syntax #
#------------------------------------#
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

#-------------------------------------------------------------------#
# Verify correct number of command line options have been specified # 
#-------------------------------------------------------------------#
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

#-----------------------------------------#
# Verify copy type is specified correctly #
#-----------------------------------------#
if [ ${Copy_Type} != "push" ] && [ ${Copy_Type} != "pull" ]
then
   printf "\t\t*** Error - invalid copy type ('${Copy_Type}') specified ***\n"
   print_usage
   exit 9
fi

#---------------------------#
# Display options specified #
#---------------------------#
printf "\tThe following options have been specified:\n"
printf "\t\tCopy Type:\t${Copy_Type}\n"
printf "\t\tRemote Host:\t${Remote_Host}\n"
printf "\t\tRemote Account:\t${Remote_Account}\n"
printf "\t\tKey File:\t${Key_File}\n"
printf "\t\tData Source:\t${Source_Dir}\n"
printf "\t\tData Target:\t${Target_Dir}\n"

#---------------------------------------------------------------------------#
# Verify there are no other duplicate/old smartsync processes still running #
#---------------------------------------------------------------------------#
Prog=""
Prog=`/bin/basename $0` >/dev/null 2>&1

#----------------------------------------------------------------------------# 
# Check for any unfinished/duplicate smartsync processes - exit if any found #
#----------------------------------------------------------------------------# 
printf "\t+-----------------------------------------------------------------------------+\n"
printf "\tVerifying duplicate processes.............."

if [ ! -z "`/bin/ps -C ${Prog} --no-headers -o "pid,ppid,sid,comm" | /bin/grep -v "$$ " | /bin/grep -v "<defunct>"`" ]
then
     printf "[Error - one or more instances found]\n"
     printf "\t\tDuplicate processes this session:\n"
     printf "`/bin/ps -aef | /bin/grep ${Prog} | /bin/grep -v "$$ " | /bin/grep -v grep | /bin/grep -v "<defunct>"`\n" 
     printf "\t\t*** Skipping file sync for this time period ***\n\n"  
     printf "\n                          *** `date` ***\n" 
     printf "+-------------------------------------------------------------------------------------+\n\n"
     exit 99 
fi

printf "[Confirmed - none found]\n"
printf "\t\tRunning processes this session:\n"
printf "`/bin/ps -aef | /bin/grep "$$ " | /bin/grep -v grep | /bin/grep -v "<defunct>"`\n"
printf "\t+-----------------------------------------------------------------------------+\n"

#
#--------------------------# 
# Verify host availability #
#--------------------------#
printf "\n\tVerifying remote host connectivity........."
Host_Status=""
Host_Status=`/bin/ping -c3 ${Remote_Host} > /dev/null 2>&1`
if [ $? -eq 0 ]
then
   printf "[Confirmed]\n"

   #-----------------------#
   # Verify account access # 
   #-----------------------#
   printf "\tVerifying remote account..................."
   Acct_Status=""
   Acct_Status=`/usr/bin/ssh -o NumberOfPasswordPrompts=0 -i ${Key_File} ${Remote_Account}@${Remote_Host} "uname -n | tr '[:upper:]' '[:lower:]'" > /dev/null 2>&1`
   if [ $? -eq 0 ]
   then
      printf "[Confirmed]\n"
   else
      printf "[Error - account not valid, key file not valid or inaccessible]\n"
      printf "\t\t*** Skipping file transfers for this time period***\n\n"  
      printf "\n                          *** `date` ***\n" 
      printf "+-------------------------------------------------------------------------------------+\n\n"
      exit 5
   fi

   #-------------------#
   # Verify source dir #
   #-------------------#
   printf "\tVerifying data source......................"
   if [ $Copy_Type == "push" ]
   then
      SrcDir_Status=""
      SrcDir_Status=`/bin/ls -lad ${Source_Dir} > /dev/null 2>&1`
      if [ $? -eq 0 ]
      then
         printf "[Confirmed]\n"
      else
         printf "[Error - source directory not found on ${Local_Host}]\n"
         printf "\t\t*** Skipping file transfers for this time period***\n\n"  
         printf "\n                          *** `date` ***\n" 
         printf "+-------------------------------------------------------------------------------------+\n\n"
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
         printf "\t\t*** Skipping file transfers for this time period***\n\n"  
         printf "\n                          *** `date` ***\n" 
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
      fi
    fi

   #-------------------#
   # Verify target dir # 
   #-------------------#
   printf "\tVerifying data target......................"
   if [ $Copy_Type == "push" ]
   then
      TarDir_Status=""
      TarDir_Status=`/usr/bin/ssh -i ${Key_File} ${Remote_Account}@${Remote_Host} "/bin/ls -lad ${Target_Dir}" > /dev/null 2>&1`
      if [ $? -eq 0 ]
      then
         printf "[Confirmed]\n"
      else
         printf "[Error - target directory not found on ${Remote_Host}]\n"
         printf "\t\t*** Skipping file transfers for this time period***\n\n"  
         printf "\n                          *** `date` ***\n" 
         printf "+-------------------------------------------------------------------------------------+\n\n"
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
         printf "\t\t*** Skipping file transfers for this time period***\n\n"  
         printf "\n                          *** `date` ***\n" 
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 8
      fi
   fi

   #-------------------#
   # Verify Disk Space #
   #-------------------#

#  printf "\tVerifying disk space requirements.........."
#  if [ $Copy_Type == "push" ]
#  then
      #------------------------------------------------------------------------------# 
      # Data Source directory is on the localhost - determine how much space is used #
      #------------------------------------------------------------------------------# 
#     SrcDir_Space_Used=""
#     SrcDir_Space_Used=`/usr/bin/du -sk ${Source_Dir} | /usr/bin/awk '{ print $1 }'` > /dev/null 2>&1
#     if [ $? -ne 0 ]
#     then
#        printf "[Error - Can not obtain data source disk space on ${Local_Host}]\n"
#        printf "\t\t*** Skipping file transfers for this time period***\n\n"  
#        printf "\n                          *** `date` ***\n" 
#        printf "+-------------------------------------------------------------------------------------+\n\n"
#        exit 8
#     fi

      #-------------------------------------------------------------------------------------#
      # Data Target directory is on the remote host - determine how much space is available #
      #-------------------------------------------------------------------------------------#
#     TarDir_Space_Avail=""
#     TarDir_Space_Avail=`/usr/bin/ssh -i ${Key_File} ${Remote_Account}@${Remote_Host} "/bin/df -k ${Target_Dir}" | /usr/bin/tail -1 | /usr/bin/awk '{ print $4 }'` > /dev/null 2>&1
#     if [ $? -ne 0 ]
#     then
#        printf "[Error - Can not obtain data target disk space on ${Remote_Host}]\n"
#        printf "\t\t*** Skipping file transfers for this time period***\n\n"  
#        printf "\n                          *** `date` ***\n" 
#        printf "+-------------------------------------------------------------------------------------+\n\n"
#        exit 8
#     fi

      #--------------------------------------------------------------------------------#
      # Determine whether or not the Data Target has enough space - exit if it doesn't #
      #--------------------------------------------------------------------------------#
#     if [ "${SrcDir_Space_Used}" -le "${TarDir_Space_Avail}" ]
#     then
#        printf "[Confirmed]\n"
#        printf "\t\tSource disk space required:  %16s K\n" ${SrcDir_Space_Used}
#        printf "\t\tTarget disk space available: %16s K\n" ${TarDir_Space_Avail}
#     else
#        printf "[Error - not enough space on target]\n"
#        printf "\t\tSource disk space required:  %16s K\n" ${SrcDir_Space_Used}
#        printf "\t\tTarget disk space available: %16s K\n" ${TarDir_Space_Avail}
#        printf "\n\t\t*** Skipping file transfers for this time period***\n\n"  
#        printf "\n                          *** `date` ***\n" 
#        printf "+-------------------------------------------------------------------------------------+\n\n"
#        exit 8
#     fi
#  else
      #--------------------------------------------------------------------------------# 
      # Data Source directory is on the remote host - determine how much space is used #
      #--------------------------------------------------------------------------------# 
#     SrcDir_Space_Used=""
#     SrcDir_Space_Used=`/usr/bin/ssh -i ${Key_File} ${Remote_Account}@${Remote_Host} "/usr/bin/du -sk ${Source_Dir}" | /usr/bin/awk '{ print $1 }'` > /dev/null 2>&1
#     if [ $? -ne 0 ]
#     then
#        printf "[Error - Can not obtain data source disk space on ${Remote_Host}]\n"
#        printf "\t\t*** Skipping file transfers for this time period***\n\n"  
#        printf "\n                          *** `date` ***\n" 
#        printf "+-------------------------------------------------------------------------------------+\n\n"
#        exit 8
#     fi

      #------------------------------------------------------------------------------------#
      # Data Target directory is on the local host - determine how much space is available #
      #------------------------------------------------------------------------------------#
#     TarDir_Space_Avail=""
#     TarDir_Space_Avail=`/bin/df -k ${Target_Dir} | /usr/bin/tail -1 | /usr/bin/awk '{ print $4 }'` > /dev/null 2>&1
#     if [ $? -ne 0 ]
#     then
#        printf "[Error - Can not obtain data target disk space on ${Local_Host}]\n"
#        printf "\t\t*** Skipping file transfers for this time period***\n\n"  
#        printf "\n                          *** `date` ***\n" 
#        printf "+-------------------------------------------------------------------------------------+\n\n"
#        exit 8
#     fi

      #--------------------------------------------------------------------------------#
      # Determine whether or not the Data Target has enough space - exit if it doesn't #
      #--------------------------------------------------------------------------------#
#     if [ "${SrcDir_Space_Used}" -le "${TarDir_Space_Avail}" ]
#     then
#        printf "[Confirmed]\n"
#        printf "\t\tSource disk space required:  %16s K\n" ${SrcDir_Space_Used}
#        printf "\t\tTarget disk space available: %16s K\n" ${TarDir_Space_Avail}
#     else
#        printf "[Error - not enough space on target]\n"
#        printf "\t\tSource disk space required:  %16s K\n" ${SrcDir_Space_Used}
#        printf "\t\tTarget disk space available: %16s K\n" ${TarDir_Space_Avail}
#        printf "\n\t\t*** Skipping file transfers for this time period***\n\n"  
#        printf "\n                          *** `date` ***\n" 
#        printf "+-------------------------------------------------------------------------------------+\n\n"
#        exit 8
#     fi
#  fi

   #-----------------------#
   # Verify rsync versions #
   #-----------------------#
   printf "\tVerifying rsync versions..................."

   Local_Rsync_Version=""
   Local_Rsync_Version=`/usr/bin/rsync --version | /usr/bin/head -1 | /usr/bin/awk '{ print $3 }'` > /dev/null 2>&1
   if [ $? -ne 0 ]
   then
      printf "[Error - Can not obtain rsync version on ${Local_Host}]\n"
      printf "\t\tVerify rsync is available\n\n"  
      printf "\t\t*** Skipping file transfers for this time period ***\n\n"  
      printf "\n                          *** `date` ***\n" 
      printf "+-------------------------------------------------------------------------------------+\n\n"
      exit 8
   fi

   Remote_Rsync_Version=""
   Remote_Rsync_Version=`ssh -i ${Key_File} ${Remote_Account}@${Remote_Host} "/usr/bin/rsync --version" | /usr/bin/head -1 | /usr/bin/awk '{ print $3 }'` > /dev/null 2>&1
   if [ $? -ne 0 ]
   then
      printf "[Error - Can not obtain rsync version on ${Remote_Host}]\n"
      printf "\t\tVerify rsync is available\n\n"  
      printf "\t\t*** Skipping file transfers for this time period ***\n\n"  
      printf "\n                          *** `date` ***\n" 
      printf "+-------------------------------------------------------------------------------------+\n\n"
      exit 8
   fi

   if [ "${Local_Rsync_Version}" = "${Remote_Rsync_Version}" ]
   then
      printf "[Confirmed]\n"
   else
      printf "[Warning - version mismatch, incompatibilities may occur]\n"  
   fi

   printf "\t\tLocal host:  ${Local_Rsync_Version}\n"
   printf "\t\tRemote host: ${Remote_Rsync_Version}\n"

   #----------------------#
   # Verify systems loads # 
   #----------------------#
   printf "\tVerifying system loads....................."

   Local_OS_Type=`/bin/uname`
   Remote_OS_Type=`ssh -i ${Key_File} ${Remote_Account}@${Remote_Host} "/usr/bin/uname"` > /dev/null 2>&1

   Local_Uptime=""
   Local_Uptime=`/usr/bin/uptime` > /dev/null 2>&1
   if [ $? -ne 0 ]
   then
      printf "[Error - Can not obtain system load on ${Local_Host}]\n"
      printf "\t\tSystem may be heavily loaded\n\n"  
      printf "\t\t*** Skipping file transfers for this time period ***\n\n"  
      printf "\n                          *** `date` ***\n" 
      printf "+-------------------------------------------------------------------------------------+\n\n"
      exit 8
   fi

   Remote_Uptime=""
   Remote_Uptime=`ssh -i ${Key_File} ${Remote_Account}@${Remote_Host} "/usr/bin/uptime"` > /dev/null 2>&1
   if [ $? -ne 0 ]
   then
      printf "[Error - Can not obtain system load on ${Remote_Host}]\n"
      printf "\t\tSystem may be heavily loaded\n\n"  
      printf "\t\t*** Skipping file transfers for this time period ***\n\n"  
      printf "\n                          *** `date` ***\n" 
      printf "+-------------------------------------------------------------------------------------+\n\n"
      exit 8
   fi

   #---------------#
   # Compare loads #
   #---------------#
   Local_Load=""
   Local_Load=`echo ${Local_Uptime} | /usr/bin/awk '{ print $10 }'  | /usr/bin/cut -d. -f1` > /dev/null 2>&1
   Remote_Load=""
   if [ ${Remote_OS_Type} == "Linux" ]
   then
      Remote_Load=`echo ${Remote_Uptime} | /usr/bin/awk '{ print $10 }' | /usr/bin/cut -d. -f1` > /dev/null 2>&1
   elif [ ${Remote_OS_Type} == "Darwin" ]
   then
      Remote_Load=`echo ${Remote_Uptime} | /usr/bin/awk '{ print $11 }' | /usr/bin/cut -d. -f1` > /dev/null 2>&1
   else
      Remote_Load=`echo ${Remote_Uptime} | /usr/bin/awk '{ print $10 }' | /usr/bin/cut -d. -f1` > /dev/null 2>&1
   fi

   if [ ${Local_Load} -ge 20 ] 
   then
      printf "[Warning - system load is high on ${Local_Host}]\n"  
      printf "\t\tLocal host uptime: ${Local_Uptime}\n\n"
      printf "\t\t*** Skipping file transfers for this time period ***\n\n"  
      printf "\n                          *** `date` ***\n" 
      printf "+-------------------------------------------------------------------------------------+\n\n"
      exit 8
   elif [ ${Remote_Load} -ge 20 ]
   then
      printf "[Warning - system load is high on ${Remote_Host}]\n"  
      printf "\t\tRemote host uptime: ${Remote_Uptime}\n\n"
      printf "\t\t*** Skipping file transfers for this time period ***\n\n"  
      printf "\n                          *** `date` ***\n" 
      printf "+-------------------------------------------------------------------------------------+\n\n"
      exit 8
   else
      printf "[Confirmed]\n"
   fi
   #-----------------------------#
   # Print uptimes for reference #
   #-----------------------------#
   printf "\t\tLocal host:  ${Local_Uptime}\n"
   printf "\t\tRemote host: ${Remote_Uptime}\n"
   printf "\t+-----------------------------------------------------------------------------+\n"

   #---------------------------------------#
   # If we made it this far - run the sync #
   #---------------------------------------#
   printf "\nFile transfers started:   `/bin/date`\n\n"

   if [ ${Copy_Type} == "push" ]
   then
      /usr/local/bin/rsync -avOWz --stats --ignore-existing --remove-sent-files -e "/usr/bin/ssh -i ${Key_File}" ${Source_Dir} ${Remote_Account}@${Remote_Host}:${Target_Dir} 
   else
      /usr/local/bin/rsync -avOWz --stats --ignore-existing --remove-sent-files -e "/usr/bin/ssh -i ${Key_File}" ${Remote_Account}@${Remote_Host}:${Source_Dir} ${Target_Dir}
   fi

   printf "\nFile transfers completed: `/bin/date`\n"

else
   #---------------------------# 
   # Let's investigate further #
   #---------------------------# 
   Bad_Host=`/bin/ping -c1 ${Remote_Host} > /dev/null 2>&1` 
   printf "Bad Host = ${Bad_Host}\n"
   if [ $Bad_Host ] 
   then
     printf "[Error - Invalid hostname specified\n"
     printf "\t\t*** Skipping file transfers for this time period***\n\n"  
     printf "\n                          *** `date` ***\n" 
     printf "+-------------------------------------------------------------------------------------+\n\n"
     exit 3
   else
     printf "[Error - Network/connectivity issue]\n" 
     printf "\t\t*** Skipping file transfers for this time period***\n\n"  
     printf "\n                          *** `date` ***\n" 
     printf "+-------------------------------------------------------------------------------------+\n\n"
     exit 4
   fi
fi

printf "\n                          *** `date` ***\n" 
printf "+-------------------------------------------------------------------------------------+\n\n"
exit 

#--------------------------------------- Fin ---------------------------------------#

