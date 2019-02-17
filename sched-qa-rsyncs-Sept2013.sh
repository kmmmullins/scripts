#! /bin/bash 

#-------------------#
# Basic necessities #
#-------------------#
Local_Host=`uname -n`


     SrcDir_Status=""
      SrcDir_Status=`/usr/bin/ssh oasprod@sky-app-1 "/bin/ls -la " > /dev/null 2>&1`
      if [ $? -eq 0 ]
      then
        printf "[Confirmed]\n"
      else
         printf "\n                          \n"
         printf "[Error - source directory not reachable on sky-app-1]\n"
         printf "\n                          \n"
         printf "\t\t*** You will need to kinit before running the rsync ***\n\n"
         printf "\n                          *** `date` ***\n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
      fi


         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"



 cd /sis/websis/non-secure
         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"
 scp -p oasprod@sky-app-1:/sis/websis/non-secure/catalog/help.html /sis/websis/non-secure/catalog/help.html
 scp -p oasprod@sky-app-1:/sis/websis/non-secure/docs/advisor.html /sis/websis/non-secure/docs/advisor.html

cd /sis/websis/secure

         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"

 scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/sfprwlst_sbemail_send.sh /sis/websis/secure/cgi-bin/sfprwlst_sbemail_send.sh
 scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/sfprwsub.sh /sis/websis/secure/cgi-bin/sfprwsub.sh
 scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-sqr/sfprwlst_sbemail.sqr /sis/websis/secure/cgi-sqr/sfprwlst_sbemail.sqr
 scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-sqr/sfprwsub.sqr /sis/websis/secure/cgi-sqr/sfprwsub.sqr
 scp -p oasprod@sky-app-1:/sis/websis/secure/docs/sfprwlst_cbemail.html /sis/websis/secure/docs/sfprwlst_cbemail.html
 scp -p oasprod@sky-app-1:/sis/websis/secure/docs/sfprwscl.html /sis/websis/secure/docs/sfprwscl.html


