#!/bin/sh -xv

LOCALHOSTNAME=`uname -n`
PUBFILE=id_rsa.pub
PUBCOPY="${PUBFILE}.${LOCALHOSTNAME}"


####  ssh-keygen -b 2048 -t rsa


LOCALFILE=`find /home/kmullins/.ssh/ -iname id_rsa.pub`
ls -la $LOCALFILE
if [ -f $LOCALFILE ]
then
echo "*****************"
cd /home/kmullins/.ssh
cp id_rsa.pub $PUBCOPY

else

echo "File not found"
fi


