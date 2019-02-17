#! /usr/build/devbld/perl/bin/perl
#-------------------------------------------------------#
# File: daily_messages                                  #
# Auth: Kevin Mullins                                   #
# Date: 05/08/98                                        #
# Desc: Script will tail messages file and print and    #
#       mail all messages for last 2 days. The systems  #
#       list keyed from ~system/database/SYSTEMS.LIST   #
#-------------------------------------------------------#

#-------------------#
# Get today's date: #
#-------------------#
(undef,undef,undef,$mday,$mon,$year) = localtime(time);
$rmon = $mon + 1;
$DATE=sprintf ("%02d%02d%02d", $rmon,$mday,$year);
$yest = ($mday - 1);

#--------------------#
# Local definitions: #
#--------------------#
$LOCAL_LOG_DIR="/usr/users/mullins";
$MESS_LOG="/usr/users/mullins/kmm_mess_$DATE";
$systems_list="/usr/users/mullins/SYSTEMS.KMM";
@HOSTS=`grep -v '#' $systems_list `; 
chomp(@HOSTS);
%kmonth = (1, Jan, 2, Feb, 3, Mar, 4, Apr, 5, May, 6, Jun, 7, Jul, 8, Aug, 9, Sep, 10, Oct, 11, Nov, 12, Dec);


chop($date = `date`);

@dateline = split(/[\t ]+/, $date);
$mmonth = $dateline[1];
$dday = $dateline[2];
$yyear = $dateline[5];
$yday = ($dday - 1);
    print ("mon..$mmonth\n");
    print ("day..$dday\n");
    print ("yday..$yday\n");
    print ("yr..$yyear\n");
     print ("...1...... $date........\nn"); 


open (LOG, "> $MESS_LOG");
   print LOG "\n+-------------------------------------------" .
    "-------------------------------------------+\n\n";
   print LOG "                 Daily Messages:   $DATE  \n";      
   print LOG "\n+-------------------------------------------" .
    "-------------------------------------------+\n\n";

#-----------------------------------------------------#
# Loop thru each system, tail the messages file,      #
# and drop each line into array, check the date       #
# for each line and if entry from  today or yesterday #
# then write to logfile and mail                      #
#-----------------------------------------------------#

for $SYSTEM (@HOSTS) {
   @node_info = split(/[\t ]+/, $SYSTEM);
   $node = $node_info[0];

   unless (open(MYFILE, "/usr/bin/rsh $node 'tail -50 /var/adm/messages' |")) {
       die ("can not open file MYFILE\n");
   }

   print LOG  "\n ******  $node   *******  \n\n";

   $line = ;
   while ($line ne "")  {
       chop ($line);
      @words = split(/[\t ]+/, $line);
     if (($mmonth eq $words[0]) and  ($dday == $words[1]) | ($yday == $words[1])) {
               print (" $line \n");
               print LOG  " $line \n";        
       }
       $line = ; 
   }
}
   close (LOG);

   #------------------------------------------#
   # Mail to root is forwarded to reops !!!!  #  
   #------------------------------------------#

   system("mailx -s 'Daily Messages $DATE ' < $MESS_LOG mullins");

