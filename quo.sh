#!/bin/bash
     
 export current="Kevin"
 export input="Mullins"

export currentip="192.168.1.1"
export newip="172.14.2.1"

echo " Current: $currentip,$newip"

 export quotcurrent="'"''${currentip}''"'"
 export quotnewip="'"''${newip}''"'"
 echo "quotes ..... $quotcurrent .... $quotnewip"





 export replacefiller="'"''$current''"','$input'"
    echo " *************** $replacefiller **************"


echo "$current - $input"


#  sudo docker exec i2b2-pg /bin/bash -c 
     echo  "##docker exec-d i2b2 -c 'update i2b2pm.pm_cell_data set url=replace(url,$quotcurrent,$quotnewip);'"




