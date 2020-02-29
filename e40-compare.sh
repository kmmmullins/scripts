#!/bin/bash

 for i in  `cat /home/kmullins/e40/e40master.txt`
 do 
#  echo $i

    echo " " 

   grep $i /home/kmullins/e40/e40nodes-41615.txt > null


   if [ $? != 0 ] 
   then 
    echo "+++++ ${i} "
    echo " ...  ${i} ... not found /n"
    echo " " 
   fi
 done


