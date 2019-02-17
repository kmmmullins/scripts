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



 cd /sis/mitsis/applications/sqr/RES
         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"
 scp oasprod@sky-app-1:/sis/mitsis/applications/sqr/RES/rcbpf_extract.sqr /sis/mitsis/applications/sqr/RES
 scp -p oasprod@sky-app-1:/sis/mitsis/applications/sqr/RES/rcbpfhot.sqr /sis/mitsis/applications/sqr/RES
 scp -p oasprod@sky-app-1:/sis/mitsis/applications/sqr/RES/rsppfchk.sqr /sis/mitsis/applications/sqr/RES

cd ../TAS

         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"
scp -p oasprod@sky-app-1:/sis/mitsis/applications/sqr/TAS/tsrbaref_to.sqr /sis/mitsis/applications/sqr/TAS
scp -p oasprod@sky-app-1:/sis/mitsis/applications/sqr/TAS/tsrbrchg.sqr    /sis/mitsis/applications/sqr/TAS
scp -p oasprod@sky-app-1:/sis/mitsis/applications/sqr/TAS/tsrbrdue_wk.sqr /sis/mitsis/applications/sqr/TAS

cd ../GEN
         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"

 scp -p oasprod@sky-app-1:/sis/mitsis/applications/sqr/GEN/glppsrpt.sqr /sis/mitsis/applications/sqr/GEN

cd /sis/mitsis/applications/scripts/TAS

  scp -p oasprod@sky-app-1:/sis/mitsis/applications/scripts/TAS/tsrbaref_batch.sh /sis/mitsis/applications/scripts/TAS
  scp -p oasprod@sky-app-1:/sis/mitsis/applications/scripts/TAS/tsrbaref_to.sh /sis/mitsis/applications/scripts/TAS
  scp -p oasprod@sky-app-1:/sis/mitsis/applications/scripts/TAS/tgpgleoy.sh /sis/mitsis/applications/scripts/TAS
  scp -p oasprod@sky-app-1:/sis/mitsis/applications/scripts/TAS/tgpglpas.sh /sis/mitsis/applications/scripts/TAS
  scp -p oasprod@sky-app-1:/sis/mitsis/applications/scripts/TAS/tpp_bur_rpts.sh /sis/mitsis/applications/scripts/TAS
  scp -p oasprod@sky-app-1:/sis/mitsis/applications/scripts/TAS/tsrdbeml.sh /sis/mitsis/applications/scripts/TAS

cd ../RES

 scp -p oasprod@sky-app-1:/sis/mitsis/applications/scripts/RES/rcbpf_extract.sh /sis/mitsis/applications/scripts/RES
 scp -p oasprod@sky-app-1:/sis/mitsis/applications/scripts/RES/rcbpfhot.sh /sis/mitsis/applications/scripts/RES


cd /sis/mitsis/applications/exe/


         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"



 scp -p oasprod@sky-app-1:/sis/mitsis/applications/exe/RES/rppfasgn.exe /sis/mitsis/applications/exe/RES


         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"

 pwd
  scp -p oasprod@sky-app-1:/sis/mitsis/applications/exe/SAT/sdpaudit.exe /sis/mitsis/applications/exe/SAT
  scp -p oasprod@sky-app-1:/sis/mitsis/applications/exe/SAT/smprafee.exe /sis/mitsis/applications/exe/SAT
  scp -p oasprod@sky-app-1:/sis/mitsis/applications/exe/SAT/slprafee.exe /sis/mitsis/applications/exe/SAT

         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"

  scp -p oasprod@sky-app-1:/sis/mitsis/applications/exe/TAS/tspapapp.exe /sis/mitsis/applications/exe/TAS
  scp -p oasprod@sky-app-1:/sis/mitsis/applications/exe/TAS/tspbastm.exe /sis/mitsis/applications/exe/TAS

cd /sis/websis/secure/cgi-bin


         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"
scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/agtlw_eecsapp_submit.sh /sis/websis/secure/cgi-bin
scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/scrci_seminar_cron.sh /sis/websis/secure/cgi-bin
scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/sfprwlst_sbemail_send.sh /sis/websis/secure/cgi-bin
scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/stv_custom_email.sh /sis/websis/secure/cgi-bin
scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/sfprwsub.sh /sis/websis/secure/cgi-bin
scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/agtlwgre_submit.sh /sis/websis/secure/cgi-bin
scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/agtlwtoecb_batch.sh /sis/websis/secure/cgi-bin
scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/agtlw_applyyourselfPhD_submit.sh /sis/websis/secure/cgi-bin
scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/agtlw_onlineapp_submit.sh /sis/websis/secure/cgi-bin
scp -p oasprod@sky-app-1:/sis/websis/secure/cgi-bin/sfprwtrm.sh /sis/websis/secure/cgi-bin
 

         printf "\n       Starting rsyncs                   \n"
         printf "\n                          \n"

rsync -avz -e ssh oasprod@sky-app-1:/sis/websis/secure/cgi-sqr /sis/websis/secure
rsync -avz -e ssh oasprod@sky-app-1:/sis/websis/non-secure/catalog /sis/websis/non-secure
rsync -avz -e ssh oasprod@sky-app-1:/sis/websis/non-secure/docs /sis/websis/non-secure
rsync -avz -e ssh oasprod@sky-app-1:/sis/websis/secure/docs /sis/websis/secure
