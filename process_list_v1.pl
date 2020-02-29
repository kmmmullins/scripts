#! /usr/bin/perl
#-----------------------------------------------#
# File: process_list.pl                         #
# Auth: Kevin Mullins                           #
# Date: 02/06/08                                #
# Desc: Simple script to monitor system loads   #
#       and capture top processes running.      # 
#       Script is intended to be run from cron. #
#-----------------------------------------------#       


my $DATE = localtime time;
chomp($DATE);
my $now = `date +%Y%m%d%H%M%S`;
my $htp = `ps -ef | grep http | wc -l`;
chomp($htp);
my $oasp = `ps -ef | grep oasprod | wc -l`;
chomp($oasp);


#        print "It is now $now\n";
#       print "Date = $DATE\n";
#      print "Total number of http processes = $htp \n";
#     print "Total number of oasprod processes = $oasp \n";
    
#   print "$DATE http: $htp  OAS: $oasp \n";



$0 = "loadwatch stats";          # Simplify process table lookups #

open (LOG, ">>/home/as_cron/kmm/logs/loadwatch.log");
print (LOG "$DATE  Http Processes: $htp - OASPROD Processes $oasp\n") ;
close (LOG);

