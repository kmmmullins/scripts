#! /usr/bin/perl
#-----------------------------------------------#
# File: process_list.pl                         #
# Auth: Kevin Mullins                           #
# Date: 02/06/08                                #
# Desc: Simple script to monitor system loads   #
#       and capture top processes running.      # 
#       Script is intended to be run from cron. #
#-----------------------------------------------#       

my $loggfile = "/home/kmullins/logs/loadwatch.log";
my $DATE = localtime time;
chomp($DATE);
my $now = `date +%Y%m%d%H%M%S`;
my $htp = `ps -ef | grep http | wc -l`;
chomp($htp);
my $allp = `ps -ef | wc -l`;
my $oasp = `ps -ef | grep oasprod | wc -l`;
chomp($allp);
chomp($oasp);

#        print "It is now $now\n";
#       print "Date = $DATE\n";
#      print "Total number of http processes = $htp \n";
#     print "Total number of oasprod processes = $oasp \n";
    
#   print "$DATE http: $htp  OAS: $oasp \n";



$0 = "loadwatch stats";          # Simplify process table lookups #

open (LOG, ">> $loggfile ");
print (LOG "$DATE : All Proc $allp : Http Proc $htp : OASPROD Proc $oasp\n") ;
close (LOG);

