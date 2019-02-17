#!/bin/bash
     

  export replacefiller="'"${currentip"'"',''${IP}''  "
  echo " *************** $replacefiller **************"


#  sudo docker exec i2b2-pg /bin/bash -c 
 echo  "-d i2b2 -c 'update i2b2pm.pm_cell_data set url=replace(url,${replacefiller});'"

