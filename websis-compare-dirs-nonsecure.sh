#!/bin/bash



for i  in `cat /home/kmullins/websis/websis-dev-app-1-nonsecure-dirs.txt` ; do 
       
#echo $i
dirname=/home/kmullins/svn/education/websis/non-secure${i}
#echo "***********"
#echo " $i .... ${dirname} "
#echo "***********"

if  [ ! -d "${dirname}" ] ;
       then 
        echo "${i} not found ****************************" 
       else
#           echo "$i  found ++++++++++++++++++++++++++++++ "
       cnt=0  
     fi


  done

