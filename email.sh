#!/bin/bash
#

## Mail config
notificationTriggered=0 # email notification will be sent if logic sets this to 1

from="root@$HOSTNAME"
recipients="app-admin@mit.edu"
subject="Admin App $destWar deployed in $destHostType"
messageBody="$kerbPrincipal@$HOSTNAME recently executed tc-app-deploy.sh to deploy $destWar on $destHostType hosts:
" # close-quote on newline deliberate for formatting. Message text appended during execution.

###########################################################
emailNotification () {
## Send notification if successful deployment or if Tomcat isn't confirmed running
    if [ $notificationTriggered -eq 1 ]
        then
            # respect formatting
            messageBody="$messageBody

Deploy script executed at: $dateTime"
            ## Email deployment notification}
            printf "\nSending notification to $recipients"
            # echo "$messageBody" | /bin/mail -s "${subject}" ${recipients}
            /usr/sbin/sendmail $recipients<<EOF
subject:$subject
from:$from
to:$recipients
$messageBody
EOF

    fi
}

