#!/bin/bash

for node in websis-prod-app-1 websis-prod-app-2 websis-test-app-1 websis-test-app-2 websis-test-app-3 websis-qa-app-1 websis-qa-app-2 websis-qa-app-3 websis-dev-app-1 websis-dev-app-2 websis-sched-dev-app-1 websis-sched-test-app-1 websis-sched-test-app-2 
do


echo "  " >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "${node} & cgi-bin" >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "  " >> /home/kmullins/websis/websis-diffs.txt

diff <(ssh root@${node} ls -R /sis/websis/secure/cgi-bin) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-bin) >> /home/kmullins/websis/websis-diffs.txt



echo "  " >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "${node} & cgi-sqr" >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "  " >> /home/kmullins/websis/websis-diffs.txt

diff <(ssh root@${node} ls -R /sis/websis/secure/cgi-sqr) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-sqr) >> /home/kmullins/websis/websis-diffs.txt

echo "  " >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "${node} & cgi-data" >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "  " >> /home/kmullins/websis/websis-diffs.txt

diff <(ssh root@${node} ls -R /sis/websis/secure/cgi-data) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-data) >> /home/kmullins/websis/websis-diffs.txt

echo "  " >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "${node} & cgi-gif" >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "  " >> /home/kmullins/websis/websis-diffs.txt

diff <(ssh root@${node} ls -R /sis/websis/secure/cgi-gif) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-gif) >> /home/kmullins/websis/websis-diffs.txt




echo "  " >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "${node} & cgi-shr" >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "  " >> /home/kmullins/websis/websis-diffs.txt

diff <(ssh root@${node} ls -R /sis/websis/secure/cgi-shr) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-shr) >> /home/kmullins/websis/websis-diffs.txt

echo "  " >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "${node} & cgi-src" >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "  " >> /home/kmullins/websis/websis-diffs.txt

diff <(ssh root@${node} ls -R /sis/websis/secure/cgi-src) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-src) >> /home/kmullins/websis/websis-diffs.txt




echo "  " >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "${node} & docs" >> /home/kmullins/websis/websis-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-diffs.txt
echo "  " >> /home/kmullins/websis/websis-diffs.txt

diff <(ssh root@${node} ls -R /sis/websis/secure/docs) <(ls -1 /home/kmullins/svn/education/websis/secure/docs) >> /home/kmullins/websis/websis-diffs.txt





done



