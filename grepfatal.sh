#!/bin/bash 
#
#
APPNAME=applicationsonline-from
DATE=`date +%m%d%y%H%M%S`
CHECKFILE=/home/kmullins/tmp/a.a

## Mail config
notificationTriggered=0 # email notification will be sent if logic sets this to 1

from="root@$HOSTNAME"
recipients="kmullins@mit.edu"
subject="Fatal Error identified in $APPNAME"
messageBody=":
" # close-quote on newline deliberate for formatting. Message text appended during execution.


EmailNotification () {
## Send notification if successful deployment or if Tomcat isn't confirmed running
            ## Email deployment notification}
            printf "\nSending notification to $recipients"
            # echo "$messageBody" | /bin/mail -s "${subject}" ${recipients}
            /usr/sbin/sendmail $recipients<<EOF
subject:$subject
from:$from
to:$recipients
$mbody
EOF

}

grep FATAL ${CHECKFILE}
if [ $? -eq 0 ]
 then
     echo "Found FATAL Error"
     mbody=`egrep -w 'FATAL|ERR' ${CHECKFILE}`
     EmailNotification
 else
     echo "No Fatal errors found"
fi

