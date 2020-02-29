#!/usr/bin/perl

#use strict;
#use warnings;


my($line)="";

if (open(KFILE, "/home/kmullins/scripts/datafeeds.txt")) {
        $line = <KFILE>;

        while ($line ne "") {


          print ("Checking feed for ", $line);




          $line = <KFILE>;
        }
}


