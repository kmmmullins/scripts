

if [[ $IP ]];
   then
   echo "using given IP $IP"

else
        IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
        echo "IP:$IP"
fi


#$BLACKLIST = array(
#       "http://127.0.0.1:9090/test",
#       "http://127.0.0.1:9090/test"
#       );


#$WHITELIST = array(
#        "http" . (($_SERVER['SERVER_PORT'] == '443') ? 's' : '' ) . "://" . $_SERVER['HTTP_HOST'],
#        "http://services.i2b2.org",
        "http://127.0.0.1:9090",
        "http://127.0.0.1:8080",
        "http://127.0.0.1",
        "http://localhost:8080",
        "http://localhost:9090",
        "http://localhost"
#	);

echo ${WHITELIST[*]}

