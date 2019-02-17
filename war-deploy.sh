#!/bin/bash
#
# tc-app-deploy.sh -- Tomcat App Deploy Script
#
# Changelog
# 2014-04-11 Delete context directory, archive WAR, chmod WAR, various revisions - gaudette
# 2014-05-12 Added support to deploy all apps from one script/one host - gaudette
# 2014-05-27 Now moving/deleting Tomcat work directory contents on redeploy. Also inlcuding tomcat container number in archived war file name to help distinguish between atlas1 adn atlas3. - gaudette

#########################
# Configuration / Setup #
#########################

##### Start app-specific config

supportedApps=( atlas1 atlas3 parking facilities sap-doc-attach persinfo events emp-newhire paystubs w2 w4 directdeposit atlas-settings )

case "$2" in
    atlas1)
	case "$1" in
            test)
            sourceTomcat=tomcat003
            destTomcat=tomcat002
            ;;
            prod)
            sourceTomcat=tomcat002
            destTomcat=tomcat002
            ;;
            *)
	esac
        warName=atlas
        devHost=atlas-dev-app-1
        testHosts=( atlas-test-app-1 atlas-test-app-2 )
        prodHosts=( atlas-prod-app-1 atlas-prod-app-2 )
    ;;
    atlas3)
        case "$1" in
            test)
            sourceTomcat=tomcat001
            destTomcat=tomcat001
            ;;
            prod)
            sourceTomcat=tomcat001
            destTomcat=tomcat001
            ;;
            *)
        esac
        warName=atlas
        devHost=atlas-dev-app-1
        testHosts=( atlas-test-app-1 atlas-test-app-2 )
        prodHosts=( atlas-prod-app-1 atlas-prod-app-2 atlas-prod-app-3 atlas-prod-app-4 )
        ;;
    parking)
        sourceTomcat=tomcat001
        destTomcat=tomcat001
        devHost=build
        testHosts=( admsys-test-app-1 admsys-test-app-2 )
        prodHosts=( admsys-prod-app-1 admsys-prod-app-2 )
        ;;
    facilities)
        sourceTomcat=tomcat002
        destTomcat=tomcat002
        warName=apps#facilities
        devHost=admsys-dev-app-1
        testHosts=( admsys-test-app-1 admsys-test-app-2 )
        prodHosts=( admsys-prod-app-1 admsys-prod-app-2 )
        ;;
    sap-doc-attach)
        sourceTomcat=tomcat002
        destTomcat=tomcat002
        warName=app#sap-doc-attach
        devHost=admsys-dev-app-1
        testHosts=( admsys-test-app-1 admsys-test-app-2 )
        prodHosts=( admsys-prod-app-1 admsys-prod-app-2 )
        ;;
    persinfo)
        sourceTomcat=tomcat003
        destTomcat=tomcat003
        devHost=admsys-dev-app-1
        testHosts=( admsys-test-app-1 admsys-test-app-2 )
        prodHosts=( admsys-prod-app-1 admsys-prod-app-2 )
        ;;
    events)
        sourceTomcat=tomcat004
        destTomcat=tomcat004
        devHost=admsys-dev-app-1
        testHosts=( admsys-test-app-1 admsys-test-app-2 )
        prodHosts=( admsys-prod-app-1 admsys-prod-app-2 )
        ;;
    emp-newhire)
        sourceTomcat=tomcat005
        destTomcat=tomcat005
        devHost=admsys-dev-app-1
        testHosts=( admsys-test-app-1 admsys-test-app-2 )
        prodHosts=( admsys-prod-app-1 admsys-prod-app-2 )
        ;;
    paystubs)
        sourceTomcat=tomcat001
        destTomcat=tomcat001
        devHost=admsys-dev-app-2
        testHosts=( admsys-test-app-3 admsys-test-app-4 )
        prodHosts=( admsys-prod-app-3 admsys-prod-app-4 )
        ;;
    w2)
        sourceTomcat=tomcat002
        destTomcat=tomcat002
        devHost=admsys-dev-app-2
        testHosts=( admsys-test-app-3 admsys-test-app-4 )
        prodHosts=( admsys-prod-app-3 admsys-prod-app-4 )
        ;;
    w4)
        sourceTomcat=tomcat003
        destTomcat=tomcat003
        devHost=admsys-dev-app-2
        testHosts=( admsys-test-app-3 admsys-test-app-4 )
        prodHosts=( admsys-prod-app-3 admsys-prod-app-4 )
        ;;
    directdeposit)
        sourceTomcat=tomcat004
        destTomcat=tomcat004
        devHost=admsys-dev-app-2
        testHosts=( admsys-test-app-3 admsys-test-app-4 )
        prodHosts=( admsys-prod-app-3 admsys-prod-app-4 )
        ;;
    atlas-settings)
        sourceTomcat=tomcat005
        destTomcat=tomcat005
        devHost=admsys-dev-app-2
        testHosts=( admsys-test-app-3 admsys-test-app-4 )
        prodHosts=( admsys-prod-app-3 admsys-prod-app-4 )
        ;;
    *)
esac

## What deployment environment is the target? Configure accordingly.
case "$1" in
    test)
        sourceHostType=Dev
        destHostType=Test
        sourceHost=$devHost
        destHosts=(${testHosts[@]})
        ;;
    prod)
        sourceHostType=Test
        destHostType=Production
        sourceHost=${testHosts[0]}
        destHosts=(${prodHosts[@]})
        ;;
        *)
esac


##### End app-specific config

dateFormat="%Y%m%d-%H%M%S"
dateTime=`date +"$dateFormat"`
tomcatStartWait=7

if [ -z $warName ] ; then warName=$2 ; fi
if [ -z $sourceWebapps ] ; then sourceWebapps=webapps ; fi
if [ -z $destWebapps ] ; then  destWebapps=webapps ; fi
if [ -z $sourceBaseDir ] ; then sourceBaseDir=/usr/local ; fi
if [ -z $destBaseDir ] ; then destBaseDir=/usr/local ; fi
if [ -z $sourceWar ] ; then sourceWar=$warName.war ; fi
if [ -z $destWar ] ; then destWar=$warName.war ; fi
if [ -z $destContext ] ; then destContext=$destBaseDir/$destTomcat/$destWebapps/$warName ; fi
if [ -z $destWorkCatalina ] ; then destWorkCatalina=$destBaseDir/$destTomcat/work/Catalina ; fi
if [ -z $destArchiveDir ] ; then destArchiveDir=/usr/local/releases/archive ; fi

## Commonly used paths
sourceWarLoc=$sourceBaseDir/$sourceTomcat/$sourceWebapps/$sourceWar
localTempWarLoc=/tmp/$destWar.$dateTime
destTempWarLoc=$destBaseDir/$destTomcat/$destWebapps/$destWar.temp
destTempArchiveLoc=$destArchiveDir/$destWar.temp.$dateTime
destArchiveLoc=$destArchiveDir/$destWar.$destTomcat.$dateTime
destTempWorkCatalina=$destArchiveDir/$warName.Catalina.$dateTime
destWarLoc=$destBaseDir/$destTomcat/$destWebapps/$destWar

## Mail config
notificationTriggered=0 # email notification will be sent if logic sets this to 1

from="root@$HOSTNAME"
recipients="app-admin@mit.edu"
subject="Admin App $destWar deployed in $destHostType"
kerbPrincipal=`klist 2>/dev/null | grep "Default principal" | awk '{print $3}' | awk -F"@" '{print $1}'`
messageBody="$kerbPrincipal@$HOSTNAME recently executed tc-app-deploy.sh to deploy $destWar on $destHostType hosts:
" # close-quote on newline deliberate for formatting. Message text appended during execution.


#############
# Functions #
#############


###########################################################

checkArgs () {
## Confirm arguments
    ## Check supportedApps array for match to 2nd argument
    for i in "${supportedApps[@]}" ; do if [ $2 ] && [ $i == $2 ] ; then validApp=$2 ; else continue ; fi ; done

    ## A) Max 2 arguments B) argument 1 must be "test" or "prod" C) did valid app name get set?
    if [ $# -ne 2 ] || [ $1 != "test" -a $1 != "prod" ] || [ -z $validApp ]
        then
            printf "\nUsage: `basename $0` [ Destination Environment ] [Application Name]\n\n"
            printf "  Available \"Destination Environment\" options:\n\n    test prod\n\n"
            printf "  Available \"Application Name\" options:\n\n    "
            for i in ${supportedApps[@]}; do printf "$i "; done
            printf "\n\n"
            exit
    fi
}


###########################################################
checkKrbTicket () {
## Confirm unexpired Kerberos Ticket for root instance
    kerbStatus=`klist 2>/dev/null | grep Default | grep "root@ATHENA.MIT.EDU" | wc -l`
    kerbExpireDate=`klist 2>/dev/null | grep krbtgt | awk '{print $3}'`
    kerbExpireTime=`klist 2>/dev/null | grep krbtgt | awk '{print $4}'`
    kerbExpireDateTime=`date --date="$kerbExpireDate $kerbExpireTime" +"$dateFormat"`
    if [ $kerbStatus -eq 1 ]
        then
            kerbName=`klist 2>/dev/null | grep Default | awk '{print $3}' | awk -F"@" '{print $2}'`
            #printf "   ...found kerberos ticket for $kerbName@ATHENA.MIT.EDU with expiration $kerbExpireDate $kerbExpireTime \n"
              if [ ${dateTime//-/} -gt ${kerbExpireDateTime//-/} ]  # removing dashes from date-time format
                then
                    printf "\nYour kerberos ticket is expired -- do \"kinit [username]/root\" to renew your ticket.\n\nExiting\n\n"
                    #printf "...your kerberos ticket is expired -- do \"kinit [username]/root\" to renew your ticket.\n\nExiting\n\n"
                    exit
              fi
        else
            printf "\nYou must \"kinit [username]/root\" to get a kerberos ticket for your [username]/root@ATHENA.MIT.EDU instance\n\nExiting\n\n"
            exit
    fi
}

###########################################################
confirmPerHost () {
## Prompt for confirmation to proceed with deploying on the identified destination host
    destHostsCount=$(( $i + 1 ))
    printf "\nOperation $destHostsCount of ${#destHosts[@]}: Deploy $sourceWar from:\n\t$sourceHostType host $sourceHost:$sourceWarLoc\nto:\n\t$destHostType host ${destHosts[$i]}:$destWarLoc\n";
    printf "\nContinue with this step? [Y / N]\n"
    read userResponse
    if [ $userResponse != "Y" ] && [ $userResponse != "y" ]
        then
            printf "   ...skipping\n"
            continue
    fi
}


###########################################################
cleanTempWar () {
## Archive and delete the temporary WAR on the destination host
## (a safety measure in case the script previously bailed out)
    remoteFileTest ${destHosts[i]} $destTempWarLoc
    if [ $fileExists -eq 1 ]
        then
            printf "\nFound detritus copy of WAR file, archiving it to $destTempArchiveLoc ...\n"
            `ssh root@${destHosts[i]} "mv $destTempWarLoc $destTempArchiveLoc"`
            remoteFileTest ${destHosts[i]} $destTempArchiveLoc
            if [ $fileExists -eq 1 ]
                then
                    printf "   ...completed archiving detritus WAR file\n"
                else
                    printf "  ...archiving detritus copy failed -- archive and delete it manually\n\nExiting\n\n"
                    exit
            fi
            ## Recheck
            # printf "   ...confirming detritus WAR was deleted after archiving...\n"
            remoteFileTest ${destHosts[i]} $destTempWarLoc
            if [ $fileExists -eq 1 ]
                then
                    printf "  ...could not delete detritus WAR file $destTempWarLoc after archiving -- please delete manually and try again\n\nExiting\n\n"
                    exit
                #else
                    #printf "   ...detritus copy of WAR file was successfully deleted after archiving\n"
            fi
        else
            printf "\nNo detritus copy of WAR file found.\n"
    fi
}


###########################################################
copyNewWar () {
## Get new WAR from source host then put to destination host in temporary local location
    printf "\nGetting $sourceWar from $sourceHost...\n"
    scp root@$sourceHost:$sourceWarLoc $localTempWarLoc
    if [ -f $localTempWarLoc ]
        then
            printf "  ...successfully copied to temp location $HOST:$localTempWarLoc...\n"
        else
            printf "  ...failed, SCP command was:\n\n\tscp root@$sourceHost:$sourceWarLoc $localTempWarLoc\n\nExiting\n\n"
            exit
    fi
    # Put
    printf "\nPutting $sourceWar to $destHost temporary location...\n"
    scp $localTempWarLoc root@${destHosts[i]}:$destTempWarLoc
    rm $localTempWarLoc
    if [ -f $localTempWarLoc ]
        then
            printf "...couldn't delete $localTempWarLoc after putting, but proceeding anyway -- please clean it up manually...\n"
    fi
    remoteFileTest ${destHosts[i]} $destTempWarLoc
    if [ $fileExists -eq 1 ]
        then
            printf "  ...successfully copied to temp location $destTempWarLoc\n"
        else
            printf "  ...failed, SCP command was:\n\n\tscp $localTempWarLoc root@${destHosts[i]}:$destTempWarLoc\n\nExiting\n\n"
            exit
    fi
}


###########################################################
archiveCurrentWar () {
## Archive current WAR on destination host
    printf "\nArchiving $destWar to $destArchiveLoc...\n"
    remoteFileTest ${destHosts[i]} $destWarLoc
    if [ $fileExists -eq 1 ]
        then
            `ssh root@${destHosts[i]} "cp -p $destWarLoc $destArchiveLoc"`
            remoteFileTest ${destHosts[i]} $destArchiveLoc
            if [ $fileExists -eq 1 ]
                then
                    printf "  ...archived $destWar\n"
                else
                    printf "  ...could not archive $destWarLoc to $destArchiveLoc\nExiting\n\n"
                    exit
            fi
        else
            printf "  ...expected WAR file $destWarLoc could not be found\n\nExiting\n\n"
            exit
    fi
}


###########################################################
deleteWar () {
## Delete archived production WAR
    ## To be safe, make sure there's an archive first
    remoteFileTest ${destHosts[i]} $destArchiveLoc
    if [ $fileExists -eq 1 ]
        then
            printf "\nDeleting archived WAR $destWar...\n"
            `ssh root@${destHosts[i]} "rm -f $destWarLoc"`
            ## Local file should not exist now
            remoteFileTest ${destHosts[i]} $destWarLoc
            if [ $fileExists -eq 1 ]
                then
                    # Value of $exitMessage get appended to notification email message body
                    exitMessage="FAILED TO DELETE OLD WAR AS EXPECTED, SERVICE $destTomcat on ${destHosts[$1]} REMAINS STOPPED"
                    addToNotification	$exitMessage
                    printf "\n\n***$exitMessage***\n\nExiting\n\n"
                    exit
                else
                    printf "  ...successfully deleted old WAR after archiving\n"
            fi
        else
            printf "Can't find $destArchiveLoc\n"
            remoteFileTest ${destHosts[i]} $destWarLoc
            if [ $fileExists -eq 1 ]
                then
                    archiveCurrentWar
                    deleteWar
            else
                exitMessage="COULD NOT FIND OLD WAR TO DELETE AND COULD NOT FIND ITS NEW ARCHIVE COPY, SERVICE $destTomcat on ${destHosts[$1]} REMAINS STOPPED"
                addToNotification	$exitMessage
                printf "\n\n***$exitMessage***\n\nExiting\n\n"
                exit
            fi
    fi
}


###########################################################
moveWar () {
    ## Move new WAR from staging to production location
    printf "\nMoving new WAR to $destWarLoc...\n"
    `ssh root@${destHosts[i]} "mv $destTempWarLoc $destWarLoc"`
    remoteFileTest ${destHosts[i]} $destWarLoc
    if [ $fileExists -eq 1 ]
        then
            printf "  ...successfully moved new WAR\n"
            # hit tripwire to send mail
            `ssh root@${destHosts[i]} "chown www:www $destWarLoc"`
        else
            printf "  ...move failed--reverting by restoring archived WAR...\n"
            revertWar
    fi
}


###########################################################
revertWar () {
## Restores archived WAR in the event of a problem deploying the new WAR
    remoteFileTest ${destHosts[i]} $destArchiveLoc
    if [ $fileExists -eq 1 ]
        then
            printf "  ...found archived WAR $destArchiveLoc...\n"
            `ssh root@${destHosts[i]} "cp -pi $destArchiveLoc $destWarLoc"`
            remoteFileTest ${destHosts[i]} $destWarLoc
            if [ $fileExists -eq 1 ]
                then
                    printf "  ...successfully restored archived WAR $destWar\n"
                else
                    # Value of $exitMessage get appended to notification email message body
                    exitMessage="FAILED TO RESTORE WAR $destWar FROM ITS ARCHIVE -- SERVICE $destTomcat on ${destHosts[$1]} REMAINS STOPPED"
                    addToNotification $exitMessage
                    printf "\n\n***$exitMessage***\n\nExiting\n\n"
                    exit
            fi
        else
            # Value of $exitMessage get appended to notification email message body
            exitMessage="FAILED TO FIND ARCHIVED WAR $destArchiveLoc -- SERVICE $destTomcat on ${destHosts[$1]} REMAINS STOPPED"
            addToNotification $exitMessage
            printf "\n\n***$exitMessage***\n\nExiting\n\n"
            exit
    fi
}


###########################################################
deleteContext () {
    ## Delete existing context directory - deploying WAR will recreated it
    remoteDirTest ${destHosts[i]} $destContext
    if [ $dirExists -eq 1 ]
        then
            printf "\nDeleting context directory $destContext...\n"
            `ssh root@${destHosts[i]} "rm -rf $destContext"`
            remoteDirTest ${destHosts[i]} $destContext
            if [ $dirExists -eq 1 ]
                then
                    # Value of $exitMessage get appended to notification email message body
                    exitMessage="FAILED TO DELETE CONTEXT DIRECTORY, SERVICE $destTomcat on ${destHosts[$1]}  REMAINS STOPPED"
                    addToNotification	$exitMessage
                    printf "\n\n***$exitMessage***\n\nExiting\n\n"
                    exit
                else
                    printf "  ...successfully deleted context directory\n"
            fi
        else
            printf "  ...did not find context directory $destContext, proceeding anyway\n"
    fi
}


###########################################################
moveWorkCatalina () {
    ## Move existing work/catalina directory - later we will delete it
    remoteDirTest ${destHosts[i]} $destWorkCatalina
    if [ $dirExists -eq 1 ]
        then
            printf "\nTemporarily moving work subdirectory $destWorkCatalina to archive area $destTempWorkCatalina...\n"
            `ssh root@${destHosts[i]} "mv $destWorkCatalina $destTempWorkCatalina"`
            remoteDirTest ${destHosts[i]} $destTempWorkCatalina
            if [ $dirExists -eq 1 ]
                then
                    printf "  ...successfully moved work catalina subdirectory\n"
                else
                    # Value of $exitMessage get appended to
notification email message body
                    exitMessage="FAILED TO MOVE WORK CATALINA SUBDIRECTORY $destWorkCatalina, SERVICE $destTomcat on ${destHosts[$1]}  REMAINS STOPPED"
                    addToNotification	$exitMessage
                    printf "\n\n***$exitMessage***\n\nExiting\n\n"
                    exit
            fi
        else
            printf "  ...did not find work catalina subdirectory $destWorkCatalina, proceeding anyway\n"
    fi
}


###########################################################
deleteWorkCatalina () {
    ## Delete backed-up work/catalina directory
#    printf "\nDeleting temporarily archived work subdirectory $destTempWorkCatalina...\n"
    remoteDirTest ${destHosts[i]} $destTempWorkCatalina
    if [ $dirExists -eq 1 ]
        then
            `ssh root@${destHosts[i]} "rm -rf $destTempWorkCatalina"`
            remoteDirTest ${destHosts[i]} $destTempWorkCatalina
# Going silent here because it's a distraction to communicate this.  So we don't need to test.
#            if [ $dirExists -eq 1 ]
#                then
                    # Value of $exitMessage get appended to notification email message body
#                    printf "...failed to move archived work catalina directory, proceeding anyway\n"
#                else
#                    printf "  ...successfully deleted work catalina subdirectory\n"
#            fi
#        else
#            printf "  ...did not find archived work catalina subdirectory $destTempWorkCatalina, proceeding anyway\n"
    fi
}


###########################################################
stopTomcat () {
## Stop and meticulously confirm Tomcat stopped
    printf "\nChecking status of tomcat service for $destTomcat...\n"
    checkTomcat
    if [ $result -ne 0 ]
        then
            printf "  ...Tomcat instance ${destTomcat} is running -- stopping it now...\n"
            `ssh root@${destHosts[i]} "/etc/init.d/$destTomcat stop"`
            # Recheck
            checkTomcat
            if [ $result -ne 0 ]
                then
                    hardKillTomcat
                else
                    printf "  ...successfully shut down $destTomcat\n"
            fi
        else
            printf "  ...$destTomcat was not running -- proceeding\n"
    fi
}


###########################################################
hardKillTomcat () {
## Kill Tomcat in the event init-based stop fails
    TOMCATPIDCHECK=`ssh root@${destHosts[i]} "ps -ef" | grep $destTomcat | grep java | awk '{print $2}'`
    pidResult=$TOMCATPIDCHECK;
    printf  "  ... /etc/init.d/$destTomcat failed -- attempting to kill pid $pidResult\n"
    ## Kill tomcat
    `ssh root@${destHosts[i]} "kill -9 $pidResult"`
    checkTomcat
    if [ $result -ne 0 ]
        then
            printf "  ...can't kill -9 $destTomcat -- use a bigger hammer\n\nExiting.\n\n."
            exit;
        else
            printf "  ...successfully shut down  $destTomcat by executing kill -9 $pidResult\n"
    fi
}


###########################################################
startTomcat () {
## Start tomcat service on destination host
    printf "\nWaiting $tomcatStartWait seconds to start $destTomcat...\n"
    notificationTriggered=1
    #  sleep $tomcatStartWait
    printf "  ...starting $destTomcat....\n"
    `ssh root@${destHosts[i]} "/etc/init.d/$destTomcat start"`
    startResult=$?
    # Seems like we need a brief wait before the return of the command and the eval of whether tomcat is running.
    sleep 2
    checkTomcat
    if [ $result -ne 0 ] && [ $startResult -eq 0 ] # Not too happy with this, would like tail of catalina.out
        then
            printf "  ...successfully started $destTomcat\n"
    else
        # Value of $exitMessage get appended to notification email message body
        exitMessage="CONFIRMATION OF SUCCESSFUL START FAILED FOR $destTomcat' ON ${destHosts[$i]} -- DO 'ps -ef | grep $destTomcat' ON ${destHosts[$i]} TO CHECK SERVICE"
        addToNotification $exitMessage
        printf "\n\n***$exitMessage\n\nExiting.\n\n"
        exit
    fi
}


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


###########################################################
addToNotification () {
## Include a specific line for this host/operation in mail message.  Can be several hosts per notification message.
    if [ "$exitMessage" ]
        then
            messageBody="$messageBody
            $exitMessage"
            subject="ERROR - $subject"
            notificationTriggered=1
            emailNotification $messageBody $subject
        else
            # respect formatting
            messageBody="$messageBody
    ${destHosts[$i]}:$destWarLoc - SUCCESS"
    fi
}


###########################################################
remoteFileTest () {
## Test for existence of a regular file
    if [ "$fileExists" ]
        then
            unset fileExists
    fi
    fileExists=`ssh root@$1 "test -f $2 && echo 1 || echo 0"`
}


###########################################################
remoteDirTest () {
## Test for existence of directory
    if [ "$dirExists" ]
        then
            unset dirExists
    fi
    dirExists=`ssh root@$1 "test -d $2 && echo 1 || echo 0"`
}


###########################################################
checkTomcat () {
## Check Tomcat Service status
    result=`ssh root@${destHosts[i]} "ps -ef" | grep $destTomcat | grep java | wc -l`
}


##########################
# Body - Bash do things! #
##########################


## Get number of ARGS right
checkArgs $@

## Confirm Kerberos ticket is present and not expired
checkKrbTicket


for i in $(seq 0 $(( ${#destHosts[@]} - 1 )))
  do

    ## Prompt for confirmation to proceed with deploying on the identified destination host
    confirmPerHost

    ## Delete detritus temporary WAR on destination host if it exists
    cleanTempWar

    # Get new WAR from source host then put to destination host in temporary location
    copyNewWar

    ## Archive the current WAR on the destination host for safekeeping/rollback
    archiveCurrentWar

    ## Stop tomcat service on destination host
    stopTomcat

    ## Delete current WAR and context dir, mv new War into position
    deleteWar

    ## Move new WAR from staging to production location
    moveWar

    ## Delete existing context directory - deploying WAR will recreated it
    deleteContext

    ## Move existing work/catalina directory - later we will delete it
    moveWorkCatalina

    ## Start tomcat service on destination host
    startTomcat

    ## Delete backed-up work/catalina directory
    deleteWorkCatalina

    ## Include a specific line for this host/operation in mail message.  Can be several hosts per notification message.
    addToNotification destHostsCount

done

## Email deployment notification -- only send if tripwire was touched indicating an actual change
emailNotification

printf "\n\nDone.\n\n"
exit
