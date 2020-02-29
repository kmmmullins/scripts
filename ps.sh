#!/bin/bash


echo $date >> /home/kmullins/logs/sky-works-3.log
echo "------" >> /home/kmullins/logs/sky-works-3.log
ps -ef | wc >> /home/kmullins/logs/sky-works-3.log
ps -ef >> /home/kmullins/logs/sky-works-3.log
echo "**********" >> /home/kmullins/logs/sky-works-3.log

