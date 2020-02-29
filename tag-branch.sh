#!/bin/bash 
#
#  release for idd svn projects  (using svn.mit.edu repository) 
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
NOBRANCHAPP=`echo $APPNAME | awk -F/ '{print $1}'`

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


##########################################################
#
#  Create Tags
#
#########################################################

CHECKBRANCH=`echo $APPNAME | grep "/"`

if [[ $? -eq 0 ]]
then
   APPN=`echo $APPNAME | sed  's/\//-/g'`
   export TAGNAME="$APPN-$BUILDNUM-$SVNREV-$DATE"
   echo ${TAGNAME}
else
   export TAGNAME="$APPNAME-$BUILDNUM-$SVNREV-$DATE"
   echo ${TAGNAME}
fi

echo "******** Creating Tag  ***********"
COPY_CMD="svn copy ${SVNBASE}/idd/${APPNAME} ${SVNBASE}/idd/${NOBRANCHAPP}/tags/$TAGNAME -m \"new-$APPN-release\""
${COPY_CMD} 


echo " "
echo "********* list **********"

list_cmd="svn list svn+ssh://svn.mit.edu/idd/${NOBRANCHAPP}/tags/"
${list_cmd} | grep $TAGNAME

if [ $? -ne 0 ]
then
  echo "There is a problem creating tag $TAGNAME"
  exit
else

echo " "
echo " A new Tag for ${APPNAME} was created called  ${TAGNAME} "
echo " "
echo "The Tagname for the ${APPNAME} deployment to test is ${TAGNAME} " | mail -s "Created new SVN Tag ${TAGNAME}" kmullins@mit.edu
exit
fi



