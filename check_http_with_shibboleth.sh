#!/bin/bash

# $Id: check_http_with_shibboleth.sh,v 1.17 2013/01/02 21:03:18 root Exp $

usage()
{
cat <<EOF

Quick and Dirty script to check the status of URLs protected by Shibboleth

Requirements: Perl, wget 1.12+

Options:
    -c : PEM file that contains your private key and certificate.
    -u : the URL that requires authentication using shibboleth.
    -s : (optional) String to search URL for (make sure to quote it)
    -v : (optional) verbose headers flag for debugging
    -p : (optional) override default SP
    -h : Show this message
EOF
    exit 1
}

VERBOSE=0

if [ $# -eq 0 ]; then
	usage
	exit
fi
while getopts "hu:p:c:s:v" OPT; do
  case $OPT in
    h)
        usage
        exit 1
        ;;
    u)
        URL=$OPTARG
        ;;
    p)
	SP=$OPTARG
	;;
    c)
        CERT=$OPTARG
        ;;
    s)
        STRING=$OPTARG
        ;;
    v)  VERBOSE=1
        ;;
    ?)
        usage
        exit
        ;;
    *)
	usage
	exit
	;;
  esac
done

URL_ENCODED=$(echo -n $URL | perl -pe 's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;')
URL_BASE=$(echo -n $URL | perl -pe 's{((?:.+?://)[^/]+).*}{$1}')
MYRANDOM=$RANDOM.$$
TMP=/tmp
COOKIE=$TMP/.cookies.$MYRANDOM
POST=$TMP/.post.$MYRANDOM
WGET=/usr/local/bin/wget
HEADERS=$TMP/.headers.$MYRANDOM
OUTPUT=$TMP/.output.$MYRANDOM
WGET_POST_FILE=$TMP/.wget_post.$MYRANDOM  #for debugging
rm -f $COOKIE $POST $HEADERS $OUTPUT $WGET_POST_FILE

# Nagios return codes
OK=0
WARNING=1
CRITICAL=2
UNKNOWN=3

if [ ! -e $CERT ]
then
      echo "CRITICAL: SSL Client certificate not found in $CERT"
		exit $CRITICAL
fi

if [ -z "${SP+xxx}" ]; then
       SP="/Shibboleth.sso/DS"
fi

# hack to get around the wayf and login through the idp without user interaction
$WGET -q -O -  --no-check-certificate --save-cookies $COOKIE --keep-session-cookies "${URL_BASE}$SP?SAMLDS=1&target=${URL_ENCODED}&entityID=https%3A%2F%2Fidp.mit.edu%2Fshibboleth" > /dev/null 2> /dev/null
$WGET -q -O $POST --keep-session-cookies --load-cookies $COOKIE --certificate=$CERT  --no-check-certificate  --save-cookies $COOKIE 'https://idp.mit.edu:446/idp/Authn/Certificate?login_certificate=Use+Certificate+-Go' > /dev/null 2> /dev/null
#WGET_POST=$(perl -lne '$url=$1 if(/<form action="(.*?)"/);$url=~s/\&#x(..);*/chr(hex($1))/eg;$relay=$1 if(/RelayState"value="(.*?)"/);$relay=~s/\&#x(..);*/chr(hex($1))/eg;$saml=$1 if(/SAMLResponse" value="(.*?)"/); END{ map { s/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg } ($relay,$saml); print qq{--post-data=RelayState=$relay&SAMLResponse=$saml $url};} ' $POST)
WGET_POST=$(perl -lne '$url=$1 if(/<form action="(.*?)"/);$url =~ s/\&#x(..);*/chr(hex($1))/eg;$relay=$1 if(/RelayState" value="(.*?)"/);$relay=~s/\&#x(..);*/chr(hex($1))/eg;$saml=$1 if(/SAMLResponse" value="(.*?)"/); END{ map { s/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg } ($relay,$saml); print qq{--post-data=RelayState=$relay&SAMLResponse=$saml $url};} ' $POST)
echo "$WGET_POST" > $WGET_POST_FILE

$WGET --server-response -O - --load-cookies $COOKIE --save-cookies $COOKIE --keep-session-cookies --no-check-certificate $WGET_POST 2> $HEADERS > $OUTPUT

# ugly.  Trying to grab just enough of the final transaction to get an HTTP response code
RESULT=`egrep -B 12 '^$' $HEADERS | egrep -A 1 "HTTP request sent, awaiting response" | egrep "HTTP/1.1" | awk '{print $2}'`

if [ $VERBOSE == "1" ]
then
	cat $HEADERS
	cat $OUTPUT
fi

# Although RFC2616 stipulates that 2xx is success and 3xx is redirection (form of success
# Only a 200 connotes success for us.  Redirection, partial content, or no content are 
# bad return codes for this type of call

if [ ! -z "${STRING+xxx}" ];
then
	MATCHES=`grep "$STRING" $OUTPUT | wc -l`
	if [ $MATCHES -ge 1 ];
	then
		echo "OK : HTTP 1.1/$RESULT : $URL : MATCHED STRING $STRING"
		RETCODE=$OK
	else 
		echo "CRITICAL: HTTP 1.1/$RESULT : $URL : NO MATCH for STRING $STRING"
		RETCODE=$CRITICAL
	fi
elif [ $RESULT == "200" ] 
then
	echo "OK : HTTP 1.1/$RESULT : $URL"
	RETCODE=$OK
elif [ $RESULT -gt 201 ] && [ $RESULT -le 599 ]
then
        echo "CRITICAL : HTTP 1.1/$RESULT : $URL"
	RETCODE=$CRITICAL
else
	echo "UNKNOWN: $RESULT : $URL"
	RETCODE=$UNKNOWN
fi

#cleanup: remove tmp file unconditionally
#if [[ $RETCODE != $UNKNOWN ]]; then 
rm $COOKIE $POST $HEADERS $OUTPUT $WGET_POST_FILE
#fi
exit $RETCODE

