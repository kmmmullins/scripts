#/bin/sh
#-------------------------------------------------------------------------------
# Description : This script will create a copy of crontabs and drop you into vi 
#-------------------------------------------------------------------------------
#
#  Variable Initialization
#
DATE_TIME=`date +'%Y-%m-%d %R'`
DATE=`date +%m%d%y%H%M`
CRONTABUSER=${USER}
CC="_cron."
ORIG=".orig"
MOD=".mod"

OFILE="${USER}$CC$DATE$ORIG"
MFILE="${USER}$CC$DATE$MOD"

#
#
#
echo "  ........Orig........$OFILE.................."
echo "  ........Mod.........$MFILE.................."
#
#
crontab -l > $OFILE
crontab -l > $MFILE 
#
echo " Diff files........................."
#
diff $OFILE $MFILE
#
#
#
#
#
vi $MFILE






