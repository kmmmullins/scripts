#!/bin/bash
#
for dfi in $(cat control-files.txt)

do
ffeed=`echo $dfi|sed 's/.\{4\}$//'`;

echo $ffeed;


ls -lat /home/datafeed/feeds/$ffeed/archive | head -4 | tail -1"




done
