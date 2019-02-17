#!/bin/bash
#
dateFormat="%Y%m%d-%H%M%S"
dateTime=`date +"$dateFormat"`



#########################
# Configuration / Setup #
#########################

##### Start app-specific config

supportedApps=( parking po w2 ) 

case "$2" in
    po)
        sourceLocation=/home/www/release
        sourceTomcat=tomcat002
        destTomcat=tomcat003
        devHost=build
        testHosts=( finsys-test-app-1 finsys-test-app-2 )
        warName=po.war
        destwarName=po.war
        ;;



    parking)
        sourceLocation=/home/www/release
        sourceTomcat=tomcat001
        destTomcat=tomcat001
        devHost=build
        testHosts=( admsys-test-app-1 admsys-test-app-2 )
        warName=$3
        destwarName=parking.war
        ;;



    w2)
        sourceLocation=/home/www/release
        sourceTomcat=tomcat002
        destTomcat=tomcat002
        devHost=build
        testHosts=( admsys-test-app-3 admsys-test-app-4 )
        warName=$3
        destwarName=w2
        ;;

    *)
esac



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

#if [ -z $warName ] ; then warName=$2 ; fi
if [ -z $sourceWebapps ] ; then sourceWebapps=webapps ; fi
if [ -z $destWebapps ] ; then  destWebapps=webapps ; fi
if [ -z $sourceBaseDir ] ; then sourceBaseDir=/home/www/release ; fi
if [ -z $destBaseDir ] ; then destBaseDir=/usr/local ; fi
if [ -z $sourceWar ] ; then sourceWar=$3 ; fi
if [ -z $destWar ] ; then destWar=$warName ; fi
if [ -z $destContext ] ; then destContext=$destBaseDir/$destTomcat/$destWebapps/$warName ; fi
if [ -z $destWorkCatalina ] ; then destWorkCatalina=$destBaseDir/$destTomcat/work/Catalina ; fi
if [ -z $destArchiveDir ] ; then destArchiveDir=/usr/local/releases/archive ; fi

## Commonly used paths
sourceWarLoc=$sourceBaseDir/$sourceWar
localTempWarLoc=/tmp/$destWar.$dateTime
destTempWarLoc=$destArchiveDir/$destWar.temp
destTempArchiveLoc=$destArchiveDir/$destWar.temp.$dateTime
destArchiveLoc=$destArchiveDir/$destWar.$destTomcat.$dateTime
destTempWorkCatalina=$destArchiveDir/$warName.Catalina.$dateTime
destWarLoc=$destBaseDir/$destTomcat/$destWebapps/$destWar
destArchivelocandwar=$destArchiveDir/$3

echo "p1 $1"
echo "p2 $2"
echo "p3 $3"

debugVariables () {

echo "p1 $1"
echo "p2 $2"
echo "p3 $3"
echo "sourceHost= $sourceHost"
echo "sourceWarLoc= $sourceWarLoc"


echo "sourceWarLoc= $sourceWarLoc"
echo "sourceBaseDir= $sourceBaseDir"
echo "localTempWarLoc= $localTempWarLoc" 
echo "destTempWarLoc= $destTempWarLoc"
echo "destTOmcat= $destTomcat"
echo "destWar.temp = $destWar.temp"
echo "desttemparchiveloc = $destTempArchiveLoc"
echo "destWarLoc= $destWarLoc"



}



###########################################################
copyNewWar () {
## Get new WAR from source host then put to destination host in temporary local location
    printf "\nGetting $sourceWar from $sourceHost...\n"
    scp root@$sourceHost:$sourceWarLoc $localTempWarLoc
    if [ -f $localTempWarLoc ] 
        then
            printf "  ...successfully copied to temp location $localTempWarLoc...\n"
        else
            printf "  ...failed, SCP command was:\n\n\tscp root@$sourceHost:$sourceWarLoc $localTempWarLoc\n\nExiting\n\n"
            exit
    fi
    ls -la $localTempWarLoc
    # Put
    printf "\nPutting $sourceWar to $destHost temporary location...\n"
    scp $localTempWarLoc root@${destHosts[i]}:$destArchivelocandwar
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
remoteFileTest () {
## Test for existence of a regular file
    if [ "$fileExists" ]
        then  
            unset fileExists
    fi  
    fileExists=`ssh root@$1 "test -f $2 && echo 1 || echo 0"`
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
checkTomcat () {
## Check Tomcat Service status
    result=`ssh root@${destHosts[i]} "ps -ef" | grep $destTomcat | grep java | wc -l`
}


###########################################################

StartTomcat () {
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
#        addToNotification $exitMessage
#        printf "\n\n***$exitMessage\n\nExiting.\n\n"
#        exit
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

renameWar () {

echo " in renameWar"






}

#################################################################################
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



#for i in $(seq 0 $(( ${#destHosts[@]} - 1 )))
#  do

 #  echo "$i"


  debugVariables 

  copyNewWar
  archiveCurrentWar
   stopTomcat
 #  deleteWar
 #  moveWar
 #  deleteContext
 #  moveWorkCatalina
 #  startTomcat


#  done

