#!/bin/bash



for i  in `cat /home/kmullins/websis/sais-sis-websis/cgi-bin.txt` ; do 
  filename=`echo $i | awk -F/ '{print $9}'` ;
  echo "filename = ${filename}" 
  for remote in `  ssh root@websis-dev-app-1 find /sis/websis/secure/cgi-bin ` ; do
#       echo $remote
       rfile=`echo $remote | awk -F/ '{print $6}'`
#       echo " rfile = $rfile"
       if  [ "${filename}" =  "${rfile}" ] ;
       then 
        echo "${filename} & ${rfile} were  found in cgi-bin on websis-dev-app-1" >> /home/kmullins/websis/websis-compare-found.log
	echo " found $rfile and $filename **************************"
       else
             echo "${filename} not found in cgi-bin on websis-dev-app-1" >> /home/kmullins/websis/websis-compare-notfound.log
       fi
       done

  done

