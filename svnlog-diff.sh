#!/bin/bash
#
#
#
DATE=`date +%m%d%y`
DATEFMT="%H:%M:%S %m/%d/%Y"
p=`pwd`
d=`dirname $p`
app=`basename $p`
wappdir=`basename $d`
###export SVN_SSH="ssh -i /var/local/etc/keystores/sais.private -l isdasnap"


#echo "wappdir: $wappdir"
#echo "app: $app"

#echo "Create release tag for $app in $wappdir"

if [ $wappdir == "idd" ];

then

info_cmd="svn info"
REVCMD=`$info_cmd | grep Revision`
SVNREV=${REVCMD:10:5}
devlog_cmd="svn log --limit 10  svn+ssh://svn.mit.edu/idd/$app/branches/dev  "
trunklog_cmd="svn log --limit 10 svn+ssh://svn.mit.edu/idd/$app/trunk "

echo "          "
echo "The current svn revision in the ${app} working directory is ${SVNREV} "
echo "          "
echo "**************** svn log of ${app} trunk  ********************"
echo "          "

$trunklog_cmd | grep " | "

echo "          "
echo "***************** svn log of ${app} dev branch  *******************"
echo "          "
$devlog_cmd  | grep " | "


exit
else

echo "You must be in the application's directory in order to release it"
echo "\" $app \": is NOT a valid application."
exit

fi







