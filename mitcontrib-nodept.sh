#!/bin/bash

 for i in  `cat /home/kmullins/mit-uniq-contributors.txt`
 do 
  echo $i

    echo " " 

wget -O - http://m.mit.edu/apis/people/\?q=$i >> /home/kmullins/mitcontrib.out

    echo "   \/n " >> /home/kmullins/mitcontrib.out 
    echo "   \/n " >> /home/kmullins/mitcontrib.out 
    echo "   \/n " >> /home/kmullins/mitcontrib.out 
    echo "   /n " >> /home/kmullins/mitcontrib.out 
    echo "   /n " >> /home/kmullins/mitcontrib.out 
#   grep $i /home/kmullins/e40/e40nodes-41615.txt > null


   if [ $? != 0 ] 
   then 
    echo "+++++ ${i} "
    echo " ...  ${i} ... not found /n"
    echo " " 
   fi
 done


