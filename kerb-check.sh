#!/bin/bash

KERBSTATUS=`klist 2>/dev/null | grep Default | wc -l`
#echo "$KERBSTATUS"


if [ $KERBSTATUS -lt 1 ]

then
 
  printf "\t\t*** Please kinit as your non-root user and try again \n"
  exit
              else
         KERBNAME=`klist 2>/dev/null | grep Default | awk '{print $3}' | awk -F"/" '{print $1}'`

         printf "\n                          \n"
         printf "Using the following Kerb id $KERBNAME \n"
         printf "\n                          \n"
         printf "+-------------------------------------------------------------------------------------+\n\n"
         exit 7
fi

