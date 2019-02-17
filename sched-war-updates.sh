#! /bin/bash 

#-------------------#
# Basic necessities #
#-------------------#
Local_Host=`uname -n`


     SrcDir_Status=""
      SrcDir_Status=`/usr/bin/ssh oasprod@sky-app-5 "/bin/ls -la " > /dev/null 2>&1`
      if [ $? -eq 0 ]
      then
        printf "[Confirmed]\n"
      else
         printf "\n                          \n"
         printf "[Error - source directory not reachable on sky-app-5]\n"
         printf "\n                          \n"
         printf "\t\t*** You will need to kinit before running the rsync ***\n\n"
         printf "\n                          *** `date` ***\n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
      fi


         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"

 
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/advisor/applications/assignadvisors/assignadvisors.war .
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/advisor/applications/sfs-ssb/sfs-ssb.war .
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/assignsupervisor/applications/assigninstructor/assigninstructor.war .
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/assignsupervisor/applications/assignsupervisor/assignsupervisor.war .
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/batchadmin/applications/batchadmin/batchadmin.war .
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/edu-apps-1/applications/etp/etp.war .
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/iap/applications/iap/iap.war .
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/onlinegrade/applications/ogs/ogs.war .
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/onlinereg/applications/onlinereg/onlinereg.war .
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/ose-rpt/applications/ose-rpt/ose-rpt.war
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/ose-rpt/applications/ose-rpt/ose-rpt.war .
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/ssit-subjeval/applications/subjeval-rpt/subjeval-rpt.war .
scp -p oracle@sky-app-5:/oracle/product/10.1.3/j2ee/ssit-subjeval/applications/subjeval/subjeval.war .





