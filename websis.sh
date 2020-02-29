#!/bin/bash
#
#
#
DATE=`date +%m%d%y%H%M`
#tempfile=/home/kmullins/tmp/sisapp-temp`$DATE`
for node in websis-prod-app-1 websis-prod-app-2 websis-test-app-1 websis-test-app-2 websis-test-app-3 websis-qa-app-1 websis-qa-app-2 websis-qa-app-3 websis-dev-app-1 websis-dev-app-2 websis-sched-dev-app-1 websis-sched-test-app-1 websis-sched-test-app-2 
do
echo " "
echo "$node  secure-files, secure-dirs,cgi-bin, cgi-data, cgi-gif, cgi-lis, cgi-restirct, cgi-shr, cgi-sqr, cgi-src, cgi-tmp, docs, publish";
echo " "
echo "**************************************************************** "
echo "********************** $node *********************************** "
echo "**************************************************************** "
echo "---- $node ---- secure-------";
ssh root@$node "find /sis/websis/secure | wc"
ssh root@$node "find /sis/websis/secure -type d | wc"
echo "---- $node ----- cgi-bin------";
ssh root@$node "find /sis/websis/secure/cgi-bin  | wc"
ssh root@$node "find /sis/websis/secure/cgi-bin  -type d | wc"
echo "---- $node ------ cgi-data -----";
ssh root@$node "find /sis/websis/secure/cgi-data  | wc"
ssh root@$node "find /sis/websis/secure/cgi-data  -type d | wc"
echo "---- $node ------ cgi-gif -----";
ssh root@$node "find /sis/websis/secure/cgi-gif   | wc"
ssh root@$node "find /sis/websis/secure/cgi-gif  -type d | wc"
echo "---- $node ------ cgi-lis -----";
ssh root@$node "find /sis/websis/secure/cgi-lis   | wc"
ssh root@$node "find /sis/websis/secure/cgi-lis  -type d | wc"
echo "---- $node ------ cgi-restrict -----";
ssh root@$node "find /sis/websis/secure/cgi-restrict  | wc"
ssh root@$node "find /sis/websis/secure/cgi-restrict  -type d | wc"
echo "---- $node ------ cgi-shr -----";
ssh root@$node "find /sis/websis/secure/cgi-shr  | wc"
ssh root@$node "find /sis/websis/secure/cgi-shr -type d | wc"
echo "---- $node ----- cgi-sqr ------";
ssh root@$node "find /sis/websis/secure/cgi-sqr   | wc"
ssh root@$node "find /sis/websis/secure/cgi-sqr  -type d | wc"
echo "---- $node -----cgi-src------";
ssh root@$node "find /sis/websis/secure/cgi-src   | wc"
ssh root@$node "find /sis/websis/secure/cgi-src  -type d | wc"
echo "---- $node ------cgi-tmp-----";
ssh root@$node "find /sis/websis/secure/cgi-tmp  | wc"
echo "---- $node -----------";
ssh root@$node "find /sis/websis/secure/cgi-tmp  -type d | wc"
echo "---- $node ------ docs -----";
ssh root@$node "find /sis/websis/secure/docs   | wc"
ssh root@$node "find /sis/websis/secure/docs  -type d | wc"
echo "---- $node -----publish------";
ssh root@$node "find /sis/websis/secure/publish   | wc"
ssh root@$node "find /sis/websis/secure/publish  -type d | wc"
echo "---- $node -----------";
echo "**************************************************************** "
echo "********************** $node *********************************** "
echo "**************************************************************** "
echo " "

done

