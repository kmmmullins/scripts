#!/bin/bash
#
#  release for idd svn projects  (using svn.mit.edu repository) 
#
#
#
DATE=`date +%m%d%y`
#echo $DATE
DATEFMT="%H:%M:%S %m/%d/%Y"
p=`pwd`
d=`dirname $p`
app=`basename $p`
wappdir=`basename $d`
#export SVN_SSH="ssh -i /var/local/etc/keystores/sais.private -l isdasnap"

LOGFILE=/home/kmullins/logs/devdeploy.log

KERBSTATUS=`klist 2>/dev/null | grep Default | wc -l`
#echo "$KERBSTATUS"


if [ $KERBSTATUS -lt 1 ]

then
       echo  `date +"${DATEFMT}" `   "Username:  "
       read USERNAME

#       echo  "${DATE}  Username: ${USERNAME} authenticated via a non-kerberos id - msr " >> $LOGFILE
 
   else
         KERBNAME=`klist 2>/dev/null | grep Default | awk '{print $3}' | awk -F"@" '{print $1}'`

         echo  "          "
         echo  "Authenticating with Kerb id $KERBNAME "
         echo  "+---------------------------------------------------------+"

         USERNAME=$KERBNAME

#       echo  "${DATE}  Username: ${USERNAME} ran msr and authenticated via kerberos id " >> $LOGFILE
fi

echo "wappdir: $wappdir"
echo "app: $app"

#svn status -u
#svn update

status_cmd="svn status -u "
SVN_SSH="ssh -q -l  $USERNAME"  ${status_cmd}



#update_cmd="svn update "
#SVN_SSH="ssh -q -l  $USERNAME"  ${update_cmd}




















##########################################################
#
#  Create Tags
#
#########################################################

exit

if [ $wappdir == "webapps" ];

then

info_cmd="svn info"

#echo  `date +"${DATEFMT}" `   "Username:  "
#read USERNAME
#USERNAME=kmullins

REVCMD=`$info_cmd | grep Revision`
SVNREV=${REVCMD:10:5}
#echo "*****  ${SVNREV} *****"

export TAGNAME="$app-$DATE-$SVNREV"

#echo ${TAGNAME}


copy_cmd="svn copy . svn+ssh://svn.mit.edu/idd/$app/tags/$TAGNAME -m \"new-$app-release\" "
list_cmd="svn list svn+ssh://svn.mit.edu/idd/$app/tags/"

echo "******** starting copy ***********"

$copy_cmd

echo "********* list **********"

$list_cmd


exit
else

echo "You must be in the application's directory in order to release it"
echo "\" $app \": is NOT a valid application."
exit

fi







