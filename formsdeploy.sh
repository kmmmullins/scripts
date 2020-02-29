#! /bin/bash 
#--------------------------------------------------------------------------------------------------#
# File: formsdeploy.sh                                                                             #
# Auth: Kevin Mullins                                                                              #
# Date: 06/25/13                                                                                   #
# Desc: Script to checkout, compile and move in place for deploument mitsis forms                  #
#--------------------------------------------------------------------------------------------------#
# Syntax: formsdeplou.sh {Form_Name} {Form_Type}                                                   #
#                                                                                                  #
#             ...where...                                                                          #
#                                                                                                  #
#         Form_Name      = valid mitsis form                                                       # 
#         Form_Type      = SAT, GEN, RES, TAS                                                      # 
#--------------------------------------------------------------------------------------------------#
#                                                                                                  #
#-------------------#
# Basic necessities #
#-------------------#
Local_Host=`uname -n`

export SVNREPO=/home/oracle/workspace/forms
export ORACLE_HOME=/oracle/product/middleware/forms
export PATH=/oracle/product/middleware/formshome/bin:/oracle/product/middleware/forms/bin:${PATH}
export JAVA_HOME=/oracle/product/middleware/forms/jdk/bin/java
export CLASSPATH=/oracle/product/middleware/forms/jlib/frmxmltools.jar:/oracle/product/middleware/forms/jlib/frmjdapi.jar:/oracle/product/middleware/forms/lib/xmlparserv2.jar:/home/oracle/build/forms/GEN:/oracle/product/middleware/forms/lib/xschema.jar
export TNS_ADMIN=/oracle/product/middleware/forms/network/admin/
export XMLTOOL=oracle.forms.util.xmltools.Forms2XML

export FORMS_PATH=$SVNREPO/SAT:/$SVNREPO/GEN:$SVNREPO/RES:$SVNREPO/TAS
export TERM=vt220
export ORACLE_TERM=vt220






#--------------------------------# 
# Command line specified options #
#--------------------------------# 
Form_Name=""
Form_Name=$1
Form_Type=""
Form_Type=$2

#------------------------------------#
# Function to display correct syntax #
#------------------------------------#
function print_usage() 
{
   printf "\n"
   printf "Usage: formsdeploy.sh {Form_Name} {Form_Type} \n\n" 
   printf "             ...where  Form_Name is a valid Mitsis form \n\n"
   printf "               and     Form_Type is SAT, GEN, RES, TAS  \n\n"
}

##printf "\n+-------------------------------------------------------------------------------------+\n"
##printf "                          *** `/bin/date` ***\n\n" 

#-------------------------------------------------------------------#
# Verify correct number of command line options have been specified # 
#-------------------------------------------------------------------#
if [ $# -lt 2 ]
then
   printf "\t\t*** Error - Missing command line options ***\n"
   print_usage
   exit 1 
fi
printf "                          *** $Form_Name $Form_Type ***\n\n" 


#-------------------------------------------------------------------#
# kinit to access svn repositiory as saisrelmgr                     # 
#-------------------------------------------------------------------#

/usr/bin/kinit -k -t /home/release-mgmt/daemon.keytab daemon/sky-works-3.mit.edu

      Kinit_Status=""
      Kinit_Status=` svn list svn+ssh://saisrelmgr@svn.mit.edu/sais-sis-mitsis/mitsis/trunk/forms > /dev/null 2>&1`
      if [ $? -eq 0 ]
      then
        printf "[ Kinit Confirmed]\n"
      else
         printf "\n                          \n"
         printf "[Error - with Kinit]\n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
      fi

     cd /home/oracle/workspace/forms

         printf "\n                          \n"
         printf "\n   `pwd`                       \n"
         printf "\n                          \n"

     svn up

      if [ $? -eq 0 ]
      then
        printf "[ svn update confirmed]\n"
      else
         printf "\n                          \n"
         printf "[Error - with svn update]\n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
      fi


#-------------------------------------------------------------------#
# kinit to access svn repositiory as saisrelmgr                     # 
#-------------------------------------------------------------------#

/oracle/product/middleware/formshome/bin/frmcmp_batch.sh Module=$Form_Name Userid=relmgr/Tajga09Rel


      if [ $? -eq 0 ]
      then
        printf "[ compile process confirmed]\n"
      else
         printf "\n                          \n"
         printf "[Error - with compile process]\n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
      fi

ls -la $SVNREPO/$FORM_TYPE/$FORM_NAME



####
## svn list svn+ssh://saisrelmgr@svn.mit.edu/sais-sis-mitsis/mitsis/trunk/forms
## svn co svn+ssh://saisrelmgr@svn.mit.edu/sais-sis-mitsis/mitsis/trunk/forms /home/oracle/workspace/forms
## svn up
## /usr/kerberos/bin/kinit -k -t /home/oracle/daemon.keytab daemon/sky-works-3.mit.edu
