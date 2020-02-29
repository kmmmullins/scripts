#!/bin/bash

 for i in  `cat /home/kmullins/nodes/oasnodes.txt`
 do 
  echo $i

#ssh root@${i} "ls -la /var/local/etc/keystores"
ssh root@${i} "ls -la /oracle/product/10.1.3/j2ee/home/config/*.jks"


   if [ $? != 0 ] 
   then 
    echo "+++++ ${i} "
    echo " ...  ${i} ... not found /n"
    echo " " 
   fi
 done


