#!/bin/bash 
#
#  tag-trunk.sh 
#
#
#
DATE=`date +%m%d%y%H%M%S`
DATEFMT="%H:%M:%S %m/%d/%Y"
LOGFILE=/home/inside/logs/tag-history.log
HOSTNAME=`hostname`
APPNAME=$1
PLANNAME=$2
SVNBASE="svn+ssh://svn.mit.edu"
STATUS_CMD="svn status -u"
UPDATE_CMD="svn update"
export SVN_SSH="ssh -i  /usr/local/etc/was/svn/sais.private -q -l isdasnap"
SVNREV=`svn log -l 1 ${SVNBASE}/idd/${APPNAME}  | grep line | awk '{print $1}' `
BUILDBASE=/var/local/bamboo/xml-data/build-dir
BUILDNUM=`grep number ${BUILDBASE}/${PLANNAME}/build-number.txt  | awk -F= '{print $2}'`
export TAGNAME="$APPNAME-$BUILDNUM-$SVNREV-$DATE"

##########################################################
#
#  Check command line
#
#########################################################

if [ $# -lt 1 ]
then

   echo " "
   echo " ERROR on the command line - no application name specified"
   echo " "
   echo " Usage tomcat-tag application-name"
   echo " "
   echo " Example: tomcat-tag w2 "
   echo " "
   exit
else
   echo " "
fi

echo "******** Creating Tag  ***********"
COPY_CMD="svn copy ${SVNBASE}/idd/${APPNAME}/trunk ${SVNBASE}/idd/${APPNAME}/tags/$TAGNAME -m \"new-$APPNAME-release\""
${COPY_CMD} 

list_cmd="svn list svn+ssh://svn.mit.edu/idd/$APPNAME/tags/"
${list_cmd} | grep $TAGNAME

if [ $? -ne 0 ]
then
  echo "There is a problem creating tag $TAGNAME"
  exit
else

echo "SVN Tag created for ${APPNAME} is called  ${TAGNAME} "
echo " "
echo "A new Tagname for ${APPNAME} was created called  ${TAGNAME} " | mail -s "Created new SVN Tag ${TAGNAME}" adm-deploy@mit.edu
exit
fi



