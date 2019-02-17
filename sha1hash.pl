#! /usr/bin/perl
#-----------------------------------------------#
# File: md5hash.pl                              #
# Auth: Kevin Mullins                           #
# Date: 07/09/2013                              #
# Desc: Script to convert a md5hash             #
#-----------------------------------------------#       
use Digest::SHA1 ;

my $DATE = localtime time;
chomp($DATE);
my $now = `date +%Y%m%d%H%M%S`;
my $htp = `ps -ef | grep http | wc -l`;
chomp($htp);
my $oasp = `ps -ef | grep oasprod | wc -l`;
chomp($oasp);
my $starter = 'AzWe149kLL750b0sqtdbT0nppY27F5';
my $kerb = 'kmullins';


my $hashtext = "$starter$kerb";
my $hashedstring = md5_hex('hashtext');

#        print "It is now $now\n";
#       print "Date = $DATE\n";
#      print "Total number of http processes = $htp \n";
#     print "Total number of oasprod processes = $oasp \n";
    
#   print "$DATE http: $htp  OAS: $oasp \n";
print "starter $starter\n";
print "kerb $kerb\n";
print "hashtext $hashtext\n";
print "hashedstring $hashedstring\n";
 
 print 'Digest is ', md5_hex('$hashtext'), "\n";


