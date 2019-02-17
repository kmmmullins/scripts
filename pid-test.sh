#!/bin/bash
#
#
# for loop to run thru servers
#
# pulled out ........ earth-cafe-2 earth-chart firesafe sky-works-1 sky-works-2 sky-vault-3 earthdrop
# also pulled out ... earth-vault earth-works-2 sea-vault-2 sky-chart skydrop sky-vault-2
#

#ps -ef | grep kmullins 

PID=$!
pid_file=/home/kmullins/pid_file.txt

echo "###########"
echo $PID 
echo "###########"


echo $!




elif [ "$1" = "start" ] ; then 

   if [ ! -z "$CATALINA_PID" ]; then
    if [ -f "$CATALINA_PID" ]; then
      echo "PID file ($CATALINA_PID) found. Is Tomcat still running? Start aborted" 

      exit 1

    if [ -f "$CATALINA_PID" -a -s "$CATALINA_PID" ]; then
      echo "Non-empty PID file ($CATALINA_PID) found. Is Tomcat still running"
      pid="`cat "$CATALINA_PID"`"
      if ps -p $pid >/dev/null; then
        echo "Tomcat is probably still running with PID $pid! Start aborted" 
        exit 1
      else
        echo "Tomcat is no longer running (stale PID file)."
      fi
     fi
   fi 




