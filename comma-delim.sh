#!/bin/bash 

for n in `cat /home/confab/archive/wikispaces-todelete-round1-names.txt`
do

kvar="$n, " 
kvar2="$kvar2 $kvar"
#echo $kvar2
done
echo $kvar2
