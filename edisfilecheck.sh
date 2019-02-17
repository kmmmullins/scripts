#!/bin/bash

for edisfile in `cat /home/kmullins/Documents/jyb-files.txt`
do
grep $edisfile /home/kmullins/Documents/datafeeds.txt
echo "status" $?
done


