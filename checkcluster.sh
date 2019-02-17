#!/bin/bash


Md5SSH () {

FILES=$1
HOSTS=$2
USER=$3

for FILE in `echo ${FILES}`; do
   echo ${FILE}
   for HOST in `echo ${HOSTS}`; do
      echo -n "${HOST}: "
      ssh ${USER}@${HOST} "md5sum ${FILE} | cut -d' ' -f1"
   done
   echo
done
}

DiffSSH () {

HOST1=$1
FILE1=$2
HOST2=$3
FILE2=$4

echo "Comparing: ${HOST1}:${FILE1} to ${HOST2}:${FILE2}"
ssh ${HOST1} "ssh ${HOST2} \"cat ${FILE2}\" |  diff ${FILE1} -" && echo "Identical"
echo
}


TIER="prod"
case ${TIER} in
   test) TIERNAME="sea"; FORMS="test_app"; J2EE="test_app02" ;;
   prod) TIERNAME="sky"; FORMS="prod_forms"; J2EE="prod_app02" ;;
   *) echo "Unrecognized tier."; exit 1 ;;
esac

HOSTS="${TIERNAME}-app-1 ${TIERNAME}-app-2 ${TIERNAME}-app-3 ${TIERNAME}-app-4"
#HOSTS="${TIERNAME}-app-1 ${TIERNAME}-app-4"

echo
echo "*** Checking .ear files ***"
echo
EAR_FILES=`ssh root@${HOSTS%% *} "find /oracle/ora_app/${FORMS}/j2ee | egrep .ear$"`
Md5SSH "${EAR_FILES}" "${HOSTS}" root

EAR_FILES=`ssh root@${HOSTS%% *} "find /oracle/ora_app/${J2EE}/j2ee | egrep .ear$"`
Md5SSH "${EAR_FILES}" "${HOSTS}" root

echo
echo "*** Checking OSSO files ***"
OSSO_FILES=`ssh root@${HOSTS%% *} "find /oracle/ora_app/${FORMS}/Apache/Apache/conf/osso | egrep '.*-.*.conf$'"`
Md5SSH "${OSSO_FILES}" "${HOSTS}" root

OSSO_FILES=`ssh root@${HOSTS%% *} "find /oracle/ora_app/${J2EE}/Apache/Apache/conf/osso | egrep '.*-.*.conf$'"`
Md5SSH "${OSSO_FILES}" "${HOSTS}" root

echo
echo "*** Diff'ing Apache conf files ***"
echo

for F in `ssh root@${HOSTS%% *} "find /oracle/ora_app/${J2EE}/Apache/Apache/conf -type f | egrep .conf$ | grep -v '/osso/'"`; do
   for H in `echo ${HOSTS#* }`; do
      DiffSSH root@${HOSTS%% *} ${F} root@${H} ${F}
   done
done
