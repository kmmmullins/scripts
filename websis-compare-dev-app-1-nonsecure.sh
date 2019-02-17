#!/bin/bash


echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "websis-dev-app-1 & cgi-bin" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt

diff <(ssh root@websis-dev-app-1 ls -R /sis/websis/non-secure/cgi-bin) <(ls -1 /home/kmullins/svn/education/websis/non-secure/cgi-bin) >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt



echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "websis-dev-app-1 & cgi-sqr" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt

diff <(ssh root@websis-dev-app-1 ls -R /sis/websis/non-secure/cgi-sqr) <(ls -1 /home/kmullins/svn/education/websis/non-secure/cgi-sqr) >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt

echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "websis-dev-app-1 & cgi-data" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt

diff <(ssh root@websis-dev-app-1 ls -R /sis/websis/non-secure/cgi-data) <(ls -1 /home/kmullins/svn/education/websis/non-secure/cgi-data) >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt

echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "websis-dev-app-1 & cgi-gif" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt

diff <(ssh root@websis-dev-app-1 ls -R /sis/websis/non-secure/cgi-gif) <(ls -1 /home/kmullins/svn/education/websis/non-secure/cgi-gif) >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt



echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "websis-dev-app-1 & cgi-shr" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt

diff <(ssh root@websis-dev-app-1 ls -R /sis/websis/non-secure/cgi-shr) <(ls -1 /home/kmullins/svn/education/websis/non-secure/cgi-shr) >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt

echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "websis-dev-app-1 & cgi-src" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt

diff <(ssh root@websis-dev-app-1 ls -R /sis/websis/non-secure/cgi-src) <(ls -1 /home/kmullins/svn/education/websis/non-secure/cgi-src) >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt



echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "websis-dev-app-1 & docs" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "*****************************" >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt
echo "  " >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt

diff <(ssh root@websis-dev-app-1 ls -R /sis/websis/non-secure/docs) <(ls -1 /home/kmullins/svn/education/websis/non-secure/docs) >> /home/kmullins/websis/websis-dev-app-1-diffs-nonsecure.txt





