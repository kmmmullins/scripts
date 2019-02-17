#!/bin/bash
#
#
# for loop to run thru apps
#
#
for app in release-test pdfservic w4

do
echo app;
ssh inside@sea-app-21 'cd /home/inside/webapps/$app ; username=kmullins; /home/inside/bin/msrkb svn status -u ';
done
