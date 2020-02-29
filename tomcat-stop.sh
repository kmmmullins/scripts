#!/bin/bash



        ${TOMCAT_HOME}/bin/shutdown.sh stop



    _tcDIE=`ps -ef | grep java | grep tomcat001 | awk '{ print $2 }'`
    [ -n "$_tcDIE" ] && kill -QUIT ${_tcDIE}
        ${TOMCAT_HOME}/bin/shutdown.sh stop
        [ -n "$_tcDIE" ] && kill -KILL ${_tcDIE}
        sleep 5


