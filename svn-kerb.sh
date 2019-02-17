#!/bin/bash

KERBSTATUS=`klist 2>/dev/null | grep Default | wc -l`
#echo "$KERBSTATUS"


if [ $KERBSTATUS -lt 1 ]

then
 
  printf "\t\t*** Please kinit as your non-root user and try again \n"
  exit
              else
         KERBNAME=`klist 2>/dev/null | grep Default | awk '{print $3}' | awk -F"/" '{print $1}'`

         printf "\n                          \n"
         printf "Using the following Kerb id $KERBNAME \n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
fi

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
export SVN_SSH="ssh -i /var/local/etc/keystores/sais.private -l isdasnap"


#echo $p
#Aecho $d

echo "wappdir: $wappdir"
echo "app: $app"

#echo "Create release tag for $app in $wappdir"

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







		
#!/bin/bash
#
#  release for idd svn projects  (using svn.mit.edu repository) 
#
#
#

DATEFMT="%H:%M:%S %m/%d/%Y"
p=`pwd`
d=`dirname $p`
app=`basename $p`

wappdir=`basename $d`

#echo $p
#Aecho $d
#echo "wappdir: $wappdir"
#echo "app: $app"

echo "Create release tag for $app in $wappdir"

if [ $wappdir == "webapps" ] ||[ $wappdir == "portlets" ] || [ $wappdir == "ws" ];

then

info_cmd="svn info"
remove_cmd="svn rm svn+ssh://svn.mit.edu/idd/$app/tags/release -m \"new-$app-release\" "
copy_cmd="svn copy . svn+ssh://svn.mit.edu/idd/$app/tags/release -m \"new-$app-release\" "
list_cmd="svn list svn+ssh://svn.mit.edu/idd/$app/tags/"
#echo " $remove_cmd" 
#echo " $copy_cmd"
#msr $remove_cmd

echo  `date +"${DATEFMT}" `   "Username:  "
read USERNAME

SVNCMD=$remove_cmd


echo ""
echo "Remove old release tag -- if any"
echo "SVN_SSH=\"ssh -q -l $USERNAME \" $SVNCMD "
SVN_SSH="ssh -q -l  $USERNAME "  $SVNCMD

SVNCMD=$copy_cmd
#SVNCMD=$list_cmd
echo "Create new release tag" 
#echo $SVNCMD
echo "SVN_SSH=\"ssh -q -l $USERNAME \" $SVNCMD "

SVN_SSH="ssh -q -l  $USERNAME "  $SVNCMD
 
exit
else

echo "You must be in the application's directory in order to release it"
echo "\" $app \": is NOT a valid application."
exit

fi







