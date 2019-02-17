#!/bin/bash
#
#
# for loop to run thru apps
#
#
for app in apr-changes apr-supplements ecat emp-newhire  inspection_admin  pdfservice  safo settings vactrac apr-hires building_services epaystub jsonrfc po settings001s  vpis apr-inbox directdeposit edacca injury jvsuite rfp sap-doc-attach  termination w2 apr-leaves dlc-assessment ehsweb-training-reports inspection roomset sara training  w4

do
echo app;
ssh inside@sea-app-21 'cd /home/inside/webapps/$app ; username=kmullins; /home/inside/bin/msrkb svn status -u ';
done
