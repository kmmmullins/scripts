#!/bin/bash


echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "websis-test-app-1 & cgi-bin" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt

diff <(ssh root@websis-test-app-1 ls -R /sis/websis/secure/cgi-bin) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-bin) >> /home/kmullins/websis/websis-test-app-1-diffs.txt



echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "websis-test-app-1 & cgi-sqr" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt

diff <(ssh root@websis-test-app-1 ls -R /sis/websis/secure/cgi-sqr) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-sqr) >> /home/kmullins/websis/websis-test-app-1-diffs.txt

echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "websis-test-app-1 & cgi-data" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt

diff <(ssh root@websis-test-app-1 ls -R /sis/websis/secure/cgi-data) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-data) >> /home/kmullins/websis/websis-test-app-1-diffs.txt

echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "websis-test-app-1 & cgi-gif" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt

diff <(ssh root@websis-test-app-1 ls -R /sis/websis/secure/cgi-gif) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-gif) >> /home/kmullins/websis/websis-test-app-1-diffs.txt



echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "websis-test-app-1 & cgi-shr" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt

diff <(ssh root@websis-test-app-1 ls -R /sis/websis/secure/cgi-shr) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-shr) >> /home/kmullins/websis/websis-test-app-1-diffs.txt

echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "websis-test-app-1 & cgi-src" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt

diff <(ssh root@websis-test-app-1 ls -R /sis/websis/secure/cgi-src) <(ls -1 /home/kmullins/svn/education/websis/secure/cgi-src) >> /home/kmullins/websis/websis-test-app-1-diffs.txt



echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "websis-test-app-1 & docs" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "*****************************" >> /home/kmullins/websis/websis-test-app-1-diffs.txt
echo "  " >> /home/kmullins/websis/websis-test-app-1-diffs.txt

diff <(ssh root@websis-test-app-1 ls -R /sis/websis/secure/docs) <(ls -1 /home/kmullins/svn/education/websis/secure/docs) >> /home/kmullins/websis/websis-test-app-1-diffs.txt





