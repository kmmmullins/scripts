#!/bin/bash
#
#  release for idd svn projects  (using svn.mit.edu repository) 
#
#
#
DATE=`date +%m%d%y%H%M%S`
#echo $DATE
DATEFMT="%H:%M:%S %m/%d/%Y"
p=`pwd`
d=`dirname $p`
app=`basename $p`
wappdir=`basename $d`
#export SVN_SSH="ssh -i /var/local/etc/keystores/sais.private -l isdasnap"
LOGFILE=/home/kmullins/logs/devdeploy.log
KERBSTATUS=`klist 2>/dev/null | grep Default | wc -l`

############################################
#
# Use kerb id to authenticate to svn
#
###########################################
if [ $KERBSTATUS -lt 1 ]

then
       echo  `date +"${DATEFMT}" `   "Username:  "
       read USERNAME

   else
         KERBNAME=`klist 2>/dev/null | grep Default | awk '{print $3}' | awk -F"@" '{print $1}'`

         echo  "          "
         echo  "Authenticating with Kerb id $KERBNAME "
         echo  "+---------------------------------------------------------+"

         USERNAME=$KERBNAME

fi


############################################
#
#  SVN info, status and update
#
############################################


if [ $wappdir == "webapps" ];
then

echo " "
echo "Application Name is : $app"
echo "$app working copy SVN repository is ..."
status_cmd="svn info "
SVN_SSH="ssh -q -l  $USERNAME"  ${status_cmd} | grep URL
echo " "

status_cmd="svn status -u "
SVN_SSH="ssh -q -l  $USERNAME"  ${status_cmd} | awk '{print $1}' | grep "C"
if [ $? -lt 1 ]; then

        echo " "
        echo "ERROR - Conflict in svn repo for $app  .... ${status_cmd}"
        echo " "
        exit
   else
#       echo " "
        echo "No conflicts in $app working directory"
        echo " "
fi

update_cmd="svn update "
SVN_SSH="ssh -q -l  $USERNAME"  ${update_cmd}

if [ $? -ne 0 ] 
then
  echo "problem with svn update"
  exit
fi

else

  echo "You must be in the application's directory in order to release it"
  echo "\" $app \": is NOT a valid application."
  exit

fi

############################################
#
# Ant deploy
#
############################################

  echo " "
  echo "Starting Build .............."
  echo " "
  ant deploy

if [ $? -ne 0 ] 
then
  echo "problem with ant deploy"
  exit
fi

##########################################################
#
#  Create Tags
#
#########################################################



if [ $wappdir == "webapps" ];

then

info_cmd="svn info"

#echo  `date +"${DATEFMT}" `   "Username:  "
#read USERNAME
#USERNAME=kmullins

REVCMD=`$info_cmd | grep Revision`
SVNREV=${REVCMD:10:5}
#echo "*****  ${SVNREV} *****"
export TAGNAME="$app-$SVNREV-$DATE"
#echo ${TAGNAME}

echo "******** Creating Tag  ***********"
copy_cmd="svn copy . svn+ssh://svn.mit.edu/idd/$app/tags/$TAGNAME -m \"new-$app-release\" "
SVN_SSH="ssh -q -l  $USERNAME"  ${copy_cmd}

echo " "
#echo "********* list **********"

list_cmd="svn list svn+ssh://svn.mit.edu/idd/$app/tags/"
SVN_SSH="ssh -q -l  $USERNAME"  ${list_cmd} | grep $TAGNAME

if [ $? -ne 0 ] 
then
  echo "There is a problem creating tag $TAGNAME"
  exit
else 

echo " "
echo " The Tagname for the ${app} deployment is ${TAGNAME} "
echo " "
echo "The new deployment of ${app} was successful and a new tag ... ${TAGNAME} was created" | mail -s "Deployed ${app} & new Tag is ${TAGNAME}" adm-deploy@mit.edu 
exit

fi



else

echo "You must be in the application's directory in order to release it"
echo "\" $app \": is NOT a valid application."
exit

fi







