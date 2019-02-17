#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#
NOW=$(date +"%m-%d-%Y")
#tempfile=/home/kmullins/tmp/sisapp-temp.$NOW
for node in `cat c.c` 
do
echo $node;
#keytool -export -keystore cacerts -file $node.cer -alias $node
#keytool -import -keystore serverTrustStore.jsk -trustcacerts -alias $node -file $node.cer
echo "------filename would be $node.cer and alias is $node ---------";
done

