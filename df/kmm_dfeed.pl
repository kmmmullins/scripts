#!/usr/bin/perl 

# datafeed engine for moving data files around and into/out of the SSIT 
# environment.
#
# Usage:  dfeed [-dN] [-c] [-e] [name]
#      where: N - debug level (0-fatal 1=error, 3=warn, 4=debug1...9=debugall)
#             -c = check/verify datafeed config only
#             -d = debug level 
#             -e = exec, Internal Use Only! (allows program to exec itself to
#                     set up logging of all stderr/stdout)
#
# --------------------------------------------------------------------------

require 5.6.0;

# Pragmas
###use strict;
###use warnings;

# Standard modules
use Carp;
use Exporter;
use File::Basename;
use Getopt::Std;
use IO::File;

# Path to add-on modules
use lib (dirname($0) . "/perllib");

# Add-on modules
use Net::FTP;

# My modules


#############################################################################
#  Constants
#############

my $DEVNULL = ">/dev/null 2>&1";

# Remote commands, for SSH, by O/S...
#
# Remote directory listing command
my %LS;
$LS{unix} = "ls -ld";
$LS{vms} = "dir/size/date/width=(display=256,filename=40)";
$LS{vm} = "dir";
$LS{mswin} = "dir";
$LS{macos} = "ls -ld";

# Delete file command
my %RM;
$RM{unix} = "rm -f";
$RM{vms} = "delete";
$RM{vm} = "XXX";
$RM{mswin} = "del";
$RM{macos} = "rm -f";

# Check sum command (not currently used since all O/Ss not covered!)
#my %SUM;
#$SUM{unix} = "/usr/bin/cksum";
#$SUM{vms} = "checksum";$
#$SUM{vm} = "XXX";
#$SUM{mswin} = "cksum";
#$SUM{macos} = "/usr/bin/cksum";

# Expected file extensions for packing/unpacking files
my %EXT;
$EXT{pgp} = 'pgp';
$EXT{gpg} = 'gpg';
$EXT{gzip} = 'gz';     $EXT{gunzip} = $EXT{gzip};
$EXT{bzip} = 'bz2';    $EXT{bunzip} = $EXT{bzip};
$EXT{zip} = 'zip';     $EXT{unzip} = $EXT{zip};
$EXT{compress} = 'z';  $EXT{uncompress} = $EXT{compress};
$EXT{tar} = 'tar';     $EXT{untar} = $EXT{tar};

my $pgpOpt = " +batchmode +force";
my $gpgOpt = " --batch --no-greeting";
my $sshOpt = " -o BatchMode=yes";
my $scpOpt = " -o BatchMode=yes -pq";

# Mail command
my $thisOS = `uname -s`;
chomp $thisOS;
my $MAIL;
$MAIL = '/bin/mail' if ($thisOS eq 'Linux');
$MAIL = '/usr/bin/mailx' if ($thisOS eq 'SunOS');
$MAIL = '/usr/bin/mailx' if ($thisOS eq 'OSF1');

# Pneumonics for all message severity levels
my %LOGLEVEL = (
  'fatal'    => 0,
  'error'    => 1,
  'warn'     => 2,
  'info'     => 3,
  'none'     => 4,
  'debug'    => 5,
  'debug1'   => 5,
  'debug2'   => 6,
  'debug3'   => 7,
  'debug4'   => 8,
  'debug5'   => 9,
  'debugall' => 9,
);

#
# Reg exps of valid values for all global or feed specific config file 
# parameters/options
#
my $yesorno = "(yes|y|no|n)";
my $os = '(unix|vms|mswin|macos|vm)';
my $host = '[\w\-_.]{2,}';
my $user = '[^/:=\s]+';
my $chmodStr = '([0-7]){3}';
 
my $encryptStr 
    = "(gpg|pgp)-(pswd|user)=([^/:=]+)(/sign=(.+)/pfile=(.+))?(/bin)?(/asc)?(/rmext)?";
my $decryptStr = '(gpg|pgp)-(pswd|pfile)=(.+)(/sign)?(/bin)?';
my $packStr = "(bzip|gzip|compress|(?:tar=.+)|(?:zip=.+)|(?:$encryptStr)|chmod=$chmodStr|upper|lower|timestamp=.+)";
my $unpackStr = "(bunzip|gunzip|uncompress|untar|unzip|(?:$decryptStr))";

my %validValue = (
  'src' => "^(local:$yesorno(:[^:=]+){1,2})"
	  . '$|^(((ftp(\((asc|bin)\))?)|ssh):' 
	  . "$os:$host:$user:(pswd|key)=([^/:=]+):$yesorno" 
          . '(:[^:=]+){0,2})$',
  'dst' => '^(local:([^:=]+))'
          . '$|^(((ftp(\((asc|bin)\))?)|ssh)'
	  . ":$os:$host:$user:(pswd|key)=([^/:=]+)" 
	  . '(:[^:=]+)?)$',

  'src_unpack' => "$unpackStr(:$unpackStr)*",
  'dst_pack' => $packStr . "(:" . $packStr . ")*",
  'src_ready' => 
        '(copy|size|date|sum|(ctl:(\d*):([^:=]*))|(lck:([^:=]*)))',
  'src_ready_int' => '(\d+)',
  'src_sum_cmd' => '(.+)',
  'src_retry_cnt' => '(\d+)',
  'src_retry_int' => '(\d+)',
  'src_dup_chk' => '(name|size|sum)',
  'src_save_old_files' => '(\d+)',
  'purge_archive' => '(\d+)',
  'src_archive' => '(yes|y|no|n|gzip|(tar(:gzip)?))',
  'dst_chmod' => $chmodStr,
  'dst_case' => '(upper|lower)',
  'log_rotate_len' => '(\d+)',
  'log_level' => '(\d)',
  'history_rotate_len' => '(\d+)',
  'notify_email' => '(\w+)@(\w+)\.(\w+)',

  'notify_on_success' =>  $yesorno,
		  );


#############################################################################
# Global variables
##################

# Globals defined in the global config file
our ($SCP,$SSH,$GZIP,$GUNZIP,$BZIP,$BUNZIP,$ZIP,$UNZIP,$COMPRESS,$UNCOMPRESS,
    $PGP,$GPG,$CKSUM);

# Global confuration settings defined in global config file
our $src_ready_int;   # Interval between two 'dir' listing for determining if a
                      # file is ready (not changing)
our $src_retry_int;   # Interval between tries connecting to source 
our $src_retry_cnt;   # number of tries to connect to source and get files.
our $src_save_old_files;  # Save old files found in woirking dir at startup?
our $src_archive;     # whether and how to archive moved datafiles
our $purge_archive;   # whether to periodically purge the archive
our $log_rotate_len;  # max length of logs before automatic rotation
our $history_rotate_len; # max length of history file before auto rotation
our $log_level;       # logging level (1-9, higher is more)
our $base_dir;        # top level base dir of engine
our $notify_addr;     # global email address for notification of errors
our $notify_email;    # feed-specific notification email addr for errors
our $notify_on_success; # send email to notify_email on success


# Global logging level and default highest logged error
our $logLevel;
my $maxError = $LOGLEVEL{none};

# Master list of original incoming files and their key stats (size, checksum, 
# modified date)
my @inFiles; 
my (%inSize, %inDate, %inSum);   


#############################################################################
# Main program
##############

# - - - - - - - - - - - - - - - - 
#
# Load system/site-specific global configuration variables (a Perl script)
#
my $thisDir = dirname $0;
my $thisFile = basename $0;
$thisFile =~ '(.+)\.\w+?';  
$thisFile = $thisDir . "/" . $1 . ".conf";
(-e $thisFile)
    or doErrorExit( "Cannot find config file ($thisFile)!" );  
require $thisFile;


#
# Set hard-coded feed defaults for configuration params.  For some params, a 
# value may be specified in the global config file.  So check if specified 
# there first, and if so, use that value instead of the hard-coded default. 
#
my %feedDef = (
  'src_files' => '*',
  'path' => '',
  'ftp_mode' => 'asc',
  'src_del' => 'no',
  'src_ready' => (defined $src_ready) ? $src_ready : 'none',
  'src_ready_int' => (defined $src_ready_int) ? $src_ready_int : 10,
  'src_retry_cnt' => (defined $src_retry_cnt) ? $src_retry_cnt : 0,
  'src_retry_int' => (defined $src_retry_int) ? $src_retry_int : 60,
  'src_save_old_files' => 
	   (defined $src_save_old_files) ? $src_save_old_files : 60,
  'src_archive' => (defined $src_archive) ? $src_archive : 'no',
  'purge_archive' => (defined $purge_archive) ? $purge_archive : 0,
  'log_rotate_len' => 
    (defined $log_rotate_len) ? $log_rotate_len : 10000,  # 0=never rotate
  'history_rotate_len' => 
    (defined $history_rotate_len) ? $history_rotate_len : 0,  # 0=never rotate
  'log_level' => 
     (defined $log_level) ? $log_level : $LOGLEVEL{warn},
  'base_dir' => (defined $base_dir) ? $base_dir : $ENV{HOME},
  'notify_on_success' =>
      (defined $notify_on_success) ? $notify_on_success : 'no',
	   );

# Define common/shared dirs (these can be configured in global config file)
my $baseDir = $feedDef{base_dir}; 
my $keysDir = $baseDir . "/keys";

# Default notification email address in case of errors
$notify_addr =  "ssit-datafeed\@mit.edu"
    unless (defined $notify_addr);

# Set default place for PGP/GPG to look for key rings etc
$ENV{PGPPATH} = $keysDir . "/pgp";
$ENV{GNUPGHOME} = $keysDir . "/gnupg";


# - - - - - - - - - - - - - - - - - - - 
# 
# Parse the command line...
#
my @argvOrig = @ARGV;   # save original first
our $opt_e;             # note: these must be 'our' not 'my'!
our $opt_c;
our $opt_d;
our $opt_g;
getopts('ceg:d:');

# Get datafeed name
my $Usage = "Usage: $0 [-c] [-dN] [-g[ups] [feed-name]\n"
           . "   where:\n"
           . "      -c      = check config only\n" 
           . "      -dN     = debug level (1-9)\n" 
           . "      -g[ups] = go/jump/skip to [u]npack|[p]ack|[s]end\n";
( $#ARGV >= 0 )
   or die $Usage;
my $feed = shift(@ARGV);

#
# Define feed specific dirs and files
#
my $feedsDir = $baseDir . "/feeds";           # top level feeds dir
my $feedDir = $feedsDir . "/" . $feed;        # feed specific dir
my $tmpDir = $feedDir . "/tmp";               # temp directory
my $tmpArchDir = $tmpDir . "/archive";        # temp archive dir
my $inDir  = $feedDir . "/in";                # working dir for incoming files 
my $outDir = $feedDir . "/out";               # working dir for outgoing files
my $oldInDir = $feedDir . "/in-old";          # place to save old inDir files
my $logDir = $feedDir . "/logs";              # log file archive
my $archDir = $feedDir . "/archive";          # data file archive dir
my $ctlFile = $baseDir . "/control/" . $feed . ".ctl"; # feed control file
my $pidFile = $feedDir . "/pid";              # PID file
my $histFile = $feedDir . "/" . "history";    # file copy history
my $logFile = $feedDir . "/log";              # feed log file


# - - - - - - - - - - - - - - - - - - - - - - - - -
# 
# Read the feed specific control file (load and validate values)
#
my %cfg;
unless ( loadControlFile( $ctlFile, \%cfg, ':\s+') ) {
    doErrorExit( "Error loading config file ($ctlFile)!" );
}

# If just checking/validating the config, we're done
if ( defined $opt_c ) {
    doLog( $LOGLEVEL{warn}, "$feed config checked.");
    exit 0;
} # if 


#
# Set the logging level from various sources in this order (whichever is
# found first)
#  1) command like switch or config file value if
#  2) feed-specific value in feed-specific config file
#  3) the feed default (hard-coded or global config value)
#
if ( defined $opt_d ) {               # command line option?
    $logLevel = $opt_d;
} elsif  ( defined( $cfg{log_level} ) ) { # in feed config file?
    $logLevel = $cfg{log_level}        
} else {                              # use default
    $logLevel = $feedDef{log_level};
}

# Assign the global default value for any configurable datafeed parameter that 
# is not defined (in the feed control file)
foreach my $p ( keys %feedDef ) {
    $cfg{$p} = $feedDef{$p}
       unless( exists $cfg{$p} );
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Create directory structure for this datafeed (in case not found, i.e. the
# first time this feed is run)
foreach my $dir ($feedsDir, $feedDir, $inDir, $outDir, $tmpDir, $oldInDir, 
		 $logDir, $archDir, $tmpArchDir) {
   unless ( -d $dir ) { 
       mkdir $dir 
	   or warn "Error creating feed dir ($dir)!";
   }
} # foreach

# Create an empty history file if not found
`touch $histFile`
    unless (-e $histFile);


# - - - - - - - - - - - - - - - - - - - - - - - - -
#
# If configured to rotate the feed log and the threshold line count has been
# reached, rotate it. (If threshold is 0, never rotate the log.)
#
# First if not found, create an empty log file so test below does not fail
`touch $logFile`
    unless( -e "$logFile" );

my $len = `wc -l $logFile | awk '{print \$1}'`;
if ( ($cfg{log_rotate_len} != 0) && ($len > $cfg{log_rotate_len}) ) {
   #
   # Note: Since this is before the 'exec' this log message ends up as cron 
   # output so leave it commented out unless needed for debugging
   ###doLog( $LOGLEVEL{debug2}, "Rotating feed log file ($len lines)..." );  

   my $now = dateStamp();
   rename $logFile, "$logFile.$now";
   `$GZIP -qf $logFile.$now`;
   `mv $logFile.$now.gz $logDir/`;
   `touch $logFile`;
} # if


# - - - - - - - - - - - - - - - - - - - - - - - - - - 
#
# If we are *not* running from an interactive session re-exec ourselves now so
# we can capture all output to the feed log file.  (A cmd line switch is set
# so we don't get into a re-exec loop.)
#
if (`tty` =~ 'not') {
    if (!defined($opt_e)) {
	# Add -e flag to cmd line to avoid a recursive re-exec loop)
	my $cmd = "$0 -e";
	foreach my $arg (@argvOrig) { $cmd .= " $arg"; }

	###doLog($LOGLEVEL{warn}, "opt_e=$opt_e, cmd=$cmd" ); 
	# Re-exec ourselves... 
	exec "$cmd >>$logFile 2>&1"
	    or deErrorExit( "Error ($?) execing ourself!\n" );
    } # if not '-e' 

} else {
    # We are running interactively. All messages get displayed and not 
    # logged.  So minimally force one message into the log file logging this
    my $d = `date "+%Y-%m-%d %H:%M:%S"`;
    chomp $d;
    `echo "$d Feed run interactively (no logging!)" >>$logFile`;
} # else interactive 

doLog( $LOGLEVEL{warn}, 
       "$feed datafeed started (PID=$$). Logging at level $logLevel" )
    if ( `tty` =~ 'not' );


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Make sure the last instance of the feed is not still running.
# Abort if so.  
#
if ( -e $pidFile ) { 
   my $pid = `cat $pidFile`;
   chomp( $pid );

   `ps -p $pid $DEVNULL`;
   if ( $? == 0 ) {	    
       doLog( $LOGLEVEL{error},
	      "Datafeed $feed is already running as process $pid!" );
       exit 1;
   } # if
} # if

# Otherwise save our own PID...
`echo "$$" >$pidFile`;
doErrorExit( "Error (" . ($?>>8) . ") writing PID to PID file!" )
    if ( $? != 0 );


#
# Start of in the incoming dir
#
chdir $inDir 
    or doErrorExit( "main: Cannot chdir to $inDir!" );


#
# If finishing a previously failed feed by jumping into the middle of the
# process, jump/go there now
#
if ( defined $opt_g ) {
  if ( $opt_g =~ /u/ ) { goto GOUNPACK; }
  if ( $opt_g =~ /p/ ) { goto GOPACK; }
  if ( $opt_g =~ /s/ ) { goto GOSEND; }
  exit 1;  # should never reach here?
} # if goto option	


# - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Clean out/save any files leftover from last run saving them if required
# and archive old log files
#
# Save any old incoming files (if option specified)
if ( $cfg{src_save_old_files} > 0 ) {

   doLog( $LOGLEVEL{debug3}, "Saving old files found in working dir..." );
   foreach my $file ( glob("*") ) {
      `mv $file $oldInDir/$file`;
   }
   
   # Purge older leftover files 
   chdir $oldInDir;
   print `find . -type f -mtime +$cfg{src_save_old_files} -exec rm {} \\;`;
   chdir $inDir;

} # if

# Purge any old data from incoming work dir and temp archive area
`rm -rf $inDir/*`;
dolog( $LOGLEVEL{error}, "Error (" . ($?>>8) . ") purging incoming dir!")
    if ($? != 0);
`rm -rf $tmpArchDir/*`;
dolog( $LOGLEVEL{error}, "Error (" . ($?>>8) . ") purging temp archive!")
    if ($? != 0);

# Move any old/rotated log files found in the main feed dir to the log dir
chdir $feedDir
    or dolog( $LOGLEVEL{error}, "Error changing dir to $feedDir!" );
foreach my $file (glob "log.*") {
   `mv $file $logDir/`;
   doLog( $LOGLEVEL{warn}, "Error (" . ($?>>8) . ") moving old feed logs!" )
      if ($? != 0);
} 


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#
# Okay, setup is done and we are ready to start the main processing of the 
# feed...
#
# First, retrieve new incoming files...
#
doPullFiles()
    or doErrorExit( "Error copying files from source!" );

# Continue only if there are files copied to be processed
if ( $#inFiles < 0 ) {
    doLog( $LOGLEVEL{warn}, "No files found to be processed. Exiting..." );
    exit 0;
}

#
# Save a copy of incoming source files to temporary directory (for archiving)
#
# If archiving (config option specified)...
if ( defined $cfg{src_archive} ) {
    doLog( $LOGLEVEL{debug3}, "Archiving files to temp area..." );
       
   # Go to the incoming dir where the files are located
    chdir $inDir 
	or doErrorExit( "CD to $inDir error (" . ($?>>8) 
			 . ") to archive files!" );

   # Copy each incoming file to the temp archive area
   foreach my $file (@inFiles) {
      print `cp -p $file $tmpArchDir/`;
      doLog( $LOGLEVEL{warn},
		"Error (" . ($?>>8) . ") copying file(" . $file 
		. ") to temp archive (" . $tmpArchDir . "!" )
	  if ( $? != 0 );
   } # foreach
} # if

#
# Delete any file from the incoming dir that are not on the incoming files
# list to cleanup any cruft (e.g., from copying twice) or otherwise not ready
#
chdir $inDir;
foreach my $file ( glob "*" ) {
   if (!exists($inSize{$file})) {
      doLog( $LOGLEVEL{warn}, "Removing " . $file . " (not ready)." );
      unlink $file 
	  or doLog( $LOGLEVEL{error}, 
		    "Error removing non-ready file ($file)" );
   }
} # foreach file in inDir

# Abort now if any errors previously logged
doErrorExit( "Exiting due to previous errors!" )
    if ( $maxError <= $LOGLEVEL{error} );
	

#
# Unpack (decrypt/decompress/untar/unzip) incoming files, then pack
# (encrypt/sign/tar/compress/zip) for outgoing as needed
#
GOUNPACK: 
if ( defined $cfg{src_unpack} ) {
    doUnpack()
	or doErrorExit( "Error unpacking files!" );
}

# Abort now if any errors previously logged
doErrorExit( "Exiting due to previous errors!" )
    if ( $maxError <= $LOGLEVEL{error} );
	
GOPACK:
if ( defined $cfg{dst_pack} ) {
    doPack()
	or doErrorExit( "Error packing files!" );
}

# Abort now if any errors previously logged
doErrorExit( "Exiting due to previous errors!" )
    if ( $maxError <= $LOGLEVEL{error} );
	

#
# Send outgoing files to the configured destinations
#
GOSEND:
doPushFiles() 
    or doErrorExit( "Error copying files to one or more destinations");

# Abort now if any errors previously logged
doErrorExit( "Exiting due to previous errors!" )
    if ( $maxError <= $LOGLEVEL{error} );

	
#
# Archive all files if configured so
#
if ( defined $cfg{src_archive} ) {
    doArchiveFiles()
	or doLog( $LOGLEVEL{error}, "Error archiving files!" );
}

#
# Log a history file entry for each file processed
#
doLogHistory()
    or doLog( $LOGLEVEL{error}, "Error logging history!" );


#
# We're done!  Clean up all data files and temp files and exit
#
`rm -rf $inDir/* $tmpDir/*`; 
if ( $? != 0 ) {
    doLog( $LOGLEVEL{error}, "Error (" . ($?>>8) . ") purging working dirs!" );
}


# Abort now if any previous errors detected
doErrorExit( "Exiting due to previous errors!" )
    if ( $maxError <= $LOGLEVEL{error} );
	

#
# Success, send notification if requested
#
if ( $cfg{notify_on_success} =~ 'y' ) {
   print "Sending success email notification to $notify_addr...\n";
   print `$MAIL -s "Info: $feed datafeed success." $notify_addr </dev/null`;

   # Send to feed-specific address too if defined
   if (defined $cfg{notify_email}) {
      print "...also sending notification to $cfg{notify_email}...\n";
      print `$MAIL -s "FYI: $feed datafeed succeeded!" $cfg{notify_email} </dev/null`;
      } # if

}

doLog( $LOGLEVEL{warn}, "Done!" )
    if ( `tty` =~ 'not' );
exit 0;


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

############################################################################
# Private subroutines
#####################

#
# -------------------------------------------------------------------------
#
# Return a date/timestamp (YYYYMMDDHHMMSS) for a file
#
sub dateStamp {  

    my $now= `date +%Y%m%d%H%M%S`;
    chomp ($now);
    return $now;

} # sub dateStamp


#
# -------------------------------------------------------------------------
#
# Escapes these chars: '*?@;' in a string (for passsing to a remote cmd line)
#
sub escStr {

    my $str = shift;
    $str =~ s/\*/\\\*/go;
    $str =~ s/\?/\\\?/go;
    $str =~ s/\@/\\\@/go;
    $str =~ s/\;/\\\;/go;
    return $str;

} # sub escStr

#
# -------------------------------------------------------------------------
#
# Convert a simple shell regex into a perl one for pattern matching.  It only
# handles the most basic shell regex using '*' and '?'.
#
sub perlregexp {

    my $str = shift;
    $str =~ s/\./\\./go;
    $str =~ s/\*/(.*)/go;
    $str =~ s/\?/(.?)/go;
    print "str=$str\n";
    return $str;

} # sub perlregexp


# --------------------------------------------------------------------
#
# Exits with an error (logged), and sends notification
#
sub doErrorExit {

    my $msg = shift;
    
    # Hardcode an address in case this is called before any config files read
###    $notify_email = "broderic\@mit.edu" # XXX
    $notify_email = "ssit-datafeed\@mit.edu"
	unless( defined $notify_email );

    # Log the error
    doLog( $LOGLEVEL{fatal}, $msg );

    # Find the start of the log msgs in the log file for this pass by looking 
    # for the last "started" msg marker
    if ( -e $logFile ) {
	my $n = `tail -500 $logFile | grep -n "datafeed started." | tail -1 | cut -d: -f1`;
	if ($? == 0) {
	    $n = 100 - $n + 2;
	} else {
	    $n = 50;     # no marker, just guess the number of lines to send
	}
    } # if

    # Save original files from the incoming directory in the "old" working dir
    # and the original source files in a 'failed' tarball 
    if ( -d $inDir ) {
	chdir $inDir;    # just in case we are not already there.
        `mv * $oldInDir`;

 	my $tarball = $archDir . "/FAILED-" . dateStamp() . ".tar.gz";
	print `cd $tmpArchDir; tar czf $tarball ./`;
    }
    


    # Send notification email if not interactive, first to globally defined
    # address, then to any feed-specific defined address
    if (`tty` =~ 'not') {
      print "Sending error email notification to $notify_email...\n";
      print `tail -$n $logFile | $MAIL -s "$feed Datafeed failure (log attached)!" $notify_email`;
      if (defined $cfg{notify_email}) {
	  print "...also sending notification to $cfg{notify_email}...\n";
	  print `$MAIL -s "Warning: $feed Datafeed failed!" $cfg{notify_email} </dev/null`;
      } # if
    } # if not interactive

    # Abort with an error
    die "ERROR!";

} # sub doErrorExit


#
# --------------------------------------------------------------------
#
# Log a text message which has the supplied severity level, based on the
# logging level
#
sub doLog {

    my ($level, $msg) = @_;

    # Add a special prefix to msg
    my $pref = "";
    if ( $level == $LOGLEVEL{warn} ) {
        $pref = "[WARN]";
    } elsif ( $level == $LOGLEVEL{error} ) {
        $pref = "[ERR]";
    } elsif ( $level == $LOGLEVEL{fatal} ) {
        $pref = "[FATAL]";
    } elsif ( $level >= $LOGLEVEL{debug} ) {
        $pref = "[DEBUG]";
    }

    # If this is the most significant error, save the level
    $maxError = $level 
	if ($level > $maxError);

    # Hardcoded default logging level in case we are called before level is set
    $logLevel = $LOGLEVEL{info}
       unless defined $logLevel;

    my $now = `date "+%Y-%m-%d %H:%M:%S"`;
    chomp $now;

    # If msg level above threshold, log/print it. 
        warn $now . $pref . " " . $msg . "\n"    
	    if ( $level <= $logLevel );

    return 1;

} # end sub doLog


#
# -----------------------------------------------------------------------
#
# Archive all incoming files (and also save stats in history log).  Incoming
# files are optionally tar'd and then optionally compressed with gzip.
# The original source files are archived, which have been temporarily saved in
# the temp archive area.
#

sub doArchiveFiles {

   doLog( $LOGLEVEL{debug4}, "In doArchiveFiles..." );

   # Jump to the temp archive dir
   my $cwd = $ENV{PWD};
   chdir $tmpArchDir
      or doLog( $LOGLEVEL{error},
		"Error CDing to $tmpArchDir for archiving!" );

   # Get timestamp in case needed for filename
   my $now = `date "+%Y-%m-%d-%H%M%S"`;
   chomp $now;

   # If archiving first to a single tar file...
   if ( $cfg{src_archive} =~ 'tar' ) {
       
       doLog( $LOGLEVEL{debug3}, "TARing source files for archive..." );

       # Get a timestamp to be used in the archived tar filename
       my $tarFile = $now . ".tar";

       # If tarfile exists, add current PID to the name to avoid overwriting.
       if ( -e $tarFile ) {
	 $tarFile = $now . "-pid" . $$ . ".tar";
	 doLog( $LOGLEVEL{warn}, "Archive tar file exists!" 
		. " Archiving as " . $tarFile . " instead." );
	}
       
       # Add all the files in the incoming dir to the archive.  
       foreach my $file (@inFiles) {
	   `tar uf $archDir/$tarFile $file`;
	   doLog( $LOGLEVEL{warn}, "Error (" . ($?>>8) 
		  . ") adding $file to archive ($tarFile)!" )
	   if ( $? != 0 );
       } # foreach

       # If compressing the tarball too, do it now
       if ($cfg{src_archive} =~ 'gzip') {
	   # If gzipped tarfile already exists, add PID to filename
           $tarFile .= "." . $now . "-pid" . $$ . ".tar" 
		if ( -e "$archDir/$tarfile.gz" );
	   doLog( $LOGLEVEL{debug3}, 
		  "GZIPing source file tarball for archive..." );
	   `$GZIP $archDir/$tarFile`;
	   doLog( $LOGLEVEL{warn}, "Error (" . ($?>>8) 
	      . ") GZIPing source tarball ($tarFile) in $archDir" )
	       if ( $? != 0 );
       } # if
	
   # Else if just compressing files, do that
   } elsif ( $cfg{src_archive} =~ 'gzip' ) {

       doLog( $LOGLEVEL{debug3}, "GZIPing source files for archive..." );

      foreach my $file (@inFiles) {
	   # If gzipped file already exists, add timestamp to filename
           my $outFile = $file;
           $outFile .= "." . $now
		if ( -e "$archDir/$file.gz" );
	 rename $file, "$archDir/$outFile";
	 print `$GZIP -q $archDir/$outFile`;
         doLog( $LOGLEVEL{warn}, "Error (" . ($?>>8) 
		. ") compressing file ($file) for archive!" )
	     if ( $? != 0 );
	 # just continue as this is not a hard error
      } # foreach

   # Else, just copy the files to the archive
   } elsif ( $cfg{src_archive} =~ 'y' ) {

       doLog( $LOGLEVEL{debug3}, "Copying source files to archive..." );
       foreach my $file (@inFiles) {
	   # If archive file already exists, add timestamp to filename
           my $outFile = $file;
           $outFile .= "." . $now  
		if ( -e "$archDir/$file" );
	   rename "$tmpArchDir/$file", "$archDir/$outFile";
       } # foreach
   } elsif ( $cfg{src_archive} != 'n|no' ) {
      doLog( $LOGLEVEL{error}, "Bad src-archive ($cfg{src_archive})!" );
   } # else
 
   # Purge the archive if configured so
   if ( (defined $cfg{purge_archive}) && ($cfg{purge_archive} > 0) ) {
       doLog( $LOGLEVEL{debug2}, "Purging archive back " 
	      . $cfg{purge_archive} . " days..." );

       chdir $archDir;
       print `find . -mtime +$cfg{purge_archive} -exec rm {} \\;`;
       doLog( $LOGLEVEL{warn}, "Error (" . ($?>>8) . ") purging archive!" )
	     if ( $? != 0 );
   } # if


   # Return to original directory
   chdir $cwd
       or doLog( $LOGLEVEL{error},
		 "Error CDing back from $tmpArchDir after archiving!" );
  

   doLog( $LOGLEVEL{debug4}, "Out doArchiveFiles..." );

###   return 1;

} # sub doArchiveFiles


#
# -----------------------------------------------------------------------
#
# Logs an entry in the history file for each file processed
#

sub doLogHistory {

   doLog( $LOGLEVEL{debug4}, "In doLogHistory..." );

   # Make sure history file exists and rotate it if too long
   `touch $histFile`
       unless( -e "$histFile" );

   # Rotate the history file first if too long.
   $len = `wc -l $histFile | awk '{print \$1}'`;
   if ( ($cfg{history_rotate_len} != 0) 
	&& ($len > $cfg{history_rotate_len}) ) {
       doLog( $LOGLEVEL{debug}, "Rotating history file ($len lines)...");
       my $now = dateStamp();
       rename $histFile, $histFile.$now;
       `$GZIP -fv $histFile.$now`
	   or doLog( $LOGLEVEL{error}, "Error (" . ($?>>8) . 
		     ") compressing history file" );
       `mv $histFile.$now $logDir/`;
       `touch $histFile`;
   } # if

   # Add an entry for each file to the history file
   if ( open HIST, ">>$histFile" ) {
       my $now = `date "+%Y-%m-%d:%H:%M:%S"`;
       chomp $now;
       foreach my $file (@inFiles) {
	   printf HIST "%s: %s\t%s\t%s\t%s\n", $now, $file, $inSum{$file}, 
	               $inSize{$file}, $inDate{$file}
    	      or doLog( $LOGLEVEL{error}, "Error writing history record!" );
       }
       close HIST;

   } else {
       doLog( $LOGLEVEL{error}, 
	      "Error (" . ($?>>8) . ") opening history file ($histFile)" );
   }

   doLog( $LOGLEVEL{debug4}, "Out doLogHistory..." );

###   return 1;

} # sub doLogHistory


#
# ------------------------------------------------------------------------
#
# Load datafeed control file
#

sub loadControlFile {

   doLog( $LOGLEVEL{debug4}, "In loadControlFile..." );

   # Parse passed parameters
   my ($file, $cfg, $delim) = @_;

   # Default delimiter is whitespace
   defined $delim 
      or $delim = '\s+';

   # Abort if config file is not readable
   unless( open FILE, "<$file" ) { 
      doLog( $LOGLEVEL{error}, "Cannot read file ($file)" );
      return 0;
   }
   
   # Parse file one line at a time.  On error, don't abort until entire
   # file has been parsed
   my ($line, $key, $val, $err);
  LINE: while ( <FILE> ) {

      # Strip leading/trailing whitespace
      /^(\s*)(.*)(\s*)$/;
      $line = $2;
      next if ($line =~ '^\#');  # Skip comments
      next if ($line =~ '^$');   # Skip blank lines

      # Parse key/value from line
      $line =~ /^(\w+)(\s*)$delim(\s*)(.+)$/; 
      $key = $1;
      $val = $4;

      doLog( $LOGLEVEL{debug4}, "   cfg(" . $key . ")=" . $val );

      # 
      # Perform some validation check on the values...
      #
      # Convert key to all lowercase first. 
      $key =~ tr/A-Z/a-z/;
      my $lval = $val;       # Temp all lowercase value for local testing
      $lval =~ tr/A-Z/a-z/;

      unless( exists $validValue{$key} ) {
	  doLog( $LOGLEVEL{error}, "Bad control file key ($key)!" );
	  $err = 1;
	  next LINE;
      }

      # Validate the value, log/flag an error if found
      ###print "\nvv=$validValue{$key}\n"; # XXX
      $val =~ m/$validValue{$key}/i; 
      ###print "1=$1,2=$2,3=$3,4=$4,5=$5,6=$6,7=$7,8=$8,9=$9,10=$10,\n11=$11,12=$12,13=$13,14=$14,15=$15,16=$16,17=$17,18=$18,19=$19\n"; #XXX
      unless ( $val =~ m/$validValue{$key}/i )  {
	  doLog( $LOGLEVEL{error}, 
		 "Bad control file value for " . $key . " (" . $val . ")!" );
	  $err = 1;
	  next LINE;
      } # if

      # Make sure multiple packs/unpacks not specified
      if ( ($key =~ '(src_un|dst_)pack') && (exists $cfg->{$key}) ) {
	 doLog( $LOGLEVEL{error}, 
		"Bad control file: multiple values for $key specified!" );
	 $err = 1; 
	 next LINE;
      } # if
	  

      # Make sure GPG and password encryption/decryption not used
      if ( ($key =~ '(src|dst)_(.*)pack') && ($lval =~ 'gpg-pswd=') ) {
	 doLog( $LOGLEVEL{error}, 
		"Bad control file $1 value: GPG and passwords not allowed!" );
	 $err = 1; 
	 next LINE;
      } # if

      # Make sure PGP password encryption and signing not used together as
      # there's no way to provide both the password and signing key passphrase
      # at the same time programmatically
      if ( ($key =~ '(src|dst)_pack') && ($lval =~ 'pgp-pswd=.+/sign') ) {
	 doLog( $LOGLEVEL{error}, 
		"Bad control file $1 value: PGP password encryption and"
		. " signing not allowed together!" );
	 $err = 1;
	 next LINE;
      } # if

      # Some src/dst checks...
      if ( $key =~ '^(src|dst)$' ) {

	  # Make sure password authentication not used with SSH
	  if ( ($lval =~ '^ssh:') && ($lval =~ ':pswd=') ) {
	      doLog( $LOGLEVEL{error}, 
		     "SSH and password authentication not allowed!" );
	      $ err = 1;
	      next LINE;
	  } # if

	  # Make sure key-based authentication not used with FTP
	  if ( ($lval =~ '^ftp:') && ($lval =~ ':key=') ) {
	      doLog( $LOGLEVEL{error}, 
		     "FTP and key authentication not allowed!" );
	      $ err = 1;
	      next LINE;
	  } # if
	  
	  # VMS and FTP not supported (Net::FTP returns error)
	  if ( ($lval =~ ':vms:') and ($lval =~ /^ftp/) ) {
	      doLog( $LOGLEVEL{error}, 
		     "FTP to a VMS system not supported!" );
	      $ err = 1;
	      next LINE;
	  }

	  # VM and SSH are not supported
	  if ( ($lval =~ ':vm:') and ($lval =~ /^ssh/) ) {
	      doLog( $LOGLEVEL{error}, 
		     "SCP to a VM system not allowed!" );
	      $ err = 1;
	      next LINE;
	  }

      } # if 


      # Store the key/value in the supplied hash. Note: Src/Dst 
      # can have multiple values so store them in an array
      if ( $key =~ '^(src|dst)$' ) { 
	  if ( exists $cfg->{$key} ) { 
	      push @{ $cfg->{$key} }, $val;
	  } else {
	      $cfg->{$key} = [ $val ];
	  }
      } else {
	  # Convert all other values to lowercase (except pack/unpack which
          #  may contain passwords and/or filenames) before storing, except
          # if value could contain a file spec
	  $val =~ tr/A-Z/a-z/
	      if ( ($key !~ 'src_unpack|dst_pack') 
                  && ($key !~ 'src_ready') || ($val !~ 'ctl')); 
	  $cfg->{$key} = $val;
      } # else

   } # while (next line)

   # 
   # Perform some more "collective" validation checks now that *all*
   # params are loaded...
   #
   # Source ready check via chksum (not supported)
   if ( (exists $cfg->{src_ready}) && ($cfg->{src_ready} =~ 'sum') ) {
       doLog( $LOGLEVEL{error}, 
	      "Checksum readiness (src_ready) not supported!" );
       $err = 1;
   }

   # At least one source and one dest must be defined
   unless( (exists $cfg->{src}) && (exists $cfg->{dst}) ) {
       doLog( $LOGLEVEL{error},
	     "At least one source and one destination must be defined!" );
       $err = 1;
   }


   doLog( $LOGLEVEL{debug4}, "Out loadControlFile" );

   return (defined $err) ? 0 : 1; 

} # sub loadControlFile


#
# -----------------------------------------------------------------------
#
# Retrieve/Pull incoming files from source locations.
#

sub doPullFiles {

   doLog( $LOGLEVEL{debug4}, "In doPullFiles..." );

   #
   # We allow multiple source locations, so ...for each source specified in 
   # the config file...
   #
 SOURCE: foreach my $srcLine ( @{ $cfg{src} } ) {

      # Log the src line (but truncate it before password first so password
      # is not logged)
      my $s = `echo "$srcLine" | cut -d\: -f1-4`; 
      chomp($s);
      doLog( $LOGLEVEL{debug2}, "Processing src: $s..." );

      # Parse and validate the individual fields from the src line and check
      # the syntax. Source can be local or remote.
      #    src: <prot>:<os>:<host>:<user>:<auth>:<del>[:<path>[:<files>]]
      #         local:<del>:<path>[:<files>]
      my (%src, $ftp);

      #
      # Local source...
      if ( $srcLine =~ 'local:' ) {
	 my $extra;
	 ($src{prot}, $src{del}, $src{path}, $src{files}, $extra) 
	     = split /:/, $srcLine;
	 # Make sure all required values provided
	 unless( (defined $src{del} and defined $src{path})
		 and (not defined $extra) ) {
	    doLog( $LOGLEVEL{error}, 
	           "Bad datafeed source ($srcLine)!" );
	    next SOURCE;
	 } # unless
      #
      # Remote source...
      } else {
	 my $extra;
	 ( $src{prot}, $src{os}, $src{host}, $src{user}, $src{auth},
	   $src{del}, $src{path}, $src{files}, $extra ) = split /:/, $srcLine;
	 # Make sure all required values provided and not too many
	 unless( (defined $src{prot} and defined $src{os} 
		   and defined $src{host} and defined $src{user} 
		   and defined $src{auth} and defined $src{del})
		 and (not defined $extra) ) {
	     doLog( $LOGLEVEL{error},"Bad datafeed source ($srcLine)!" );
	     next SOURCE;
	 }


      } # else remote soruce

      # Some fields are not case-sensitive. Translate all those to all 
      # lowercase for easier comparisons
      foreach my $p qw(prot os host del) {
	 $src{$p} =~ tr/A-Z/a-z/
	    if ( exists $src{$p} ); 
      }

      # Next apply a default value any missing optional fields. Note: Optional 
      # fields that are not provided will have "undefined values in the 
      # 'src' hash 
      $src{files} = $feedDef{src_files}
         unless ( defined( $src{files} ) );
      $src{path} = $feedDef{path}
         unless ( defined( $src{path} ) );

      # Parse the auth field
      $src{auth} =~ '(pswd|key)=([^:/=]+)';
      $src{auth} = $2;

      # If [remote] protocol is SSH, make sure key file and passphrase file 
      # exist
      my $keyFile;
      if ( $src{prot} eq 'ssh' ) {
          # Assume key-based auth (pswd auth not allowed w/ SSH)
	  $keyFile = $src{auth};;
	  unless( -e "$keysDir/$keyFile" ) {
	      # Keyfile missing, skip to next source line
	      doLog( $LOGLEVEL{error}, 
		 "SSH key file ($keyFile) for source not found in $keysDir!" );
	      next SOURCE;
	  }
      } # if 

      # Parse the file path. Note: Since VM paths can have a colon (which is
      # the field separator), a '/' is used in the path instead.  So convert 
      # the '/' in the path back to a colon. 
      $src{path} =~ s|/|:|
	  if ($src{os} eq 'vm');

      # 
      # For VMS systems, a path also uses ':' so it is encoded with '/' 
      # instead.  The path is converted back to VMS format here. (E.g., 
      # E.g., Convert "/a/b/c/d/" to "a:[b.c.d]"
      if ( ($src{os} eq 'vms') && exists($src{path}) ) {
	  $src{path_orig} = $src{path};      # Save the orignal path

	  unless( $src{path}[0] ne '/' ) {
	      doLog( $LOGLEVEL{error}, "Bad VMS path ($src{path})" );
	      next SOURCE;
	  }
	  $src{path} =~ s|/||o               # Delete any leading '/'
	      if ( $src{path} =~ '^/' );
	  chop $src{path}                    # Delete any trailing '/'
	     if ( $src{path} =~ '/$' );
	  if ( $src{path} =~ '/' ) {         # If there are more '/'s
	      $src{path} =~ s|/|:\[|o;       #   Convert next one to ':['
	      $src{path} =~ tr|/|\.|;        #   Convert rest of them to '.'
	      $src{path} .= ']';             #   Append a ']'
	  } else {                           # Else it's just a logical so 
	      $src{path} .= ':';             #    append a ':'
	  }
	  $src{path} =~ tr/A-Z/a-z/;         # Lowercase the entire path
	  $src{files} =~ tr/A-Z/a-z/;        # Lowercase all filename
      }


      #
      # In case the files are not ready, loop and retry "src_retry_cnt" times
      # after waiting 'src_retry_int' seconds (interval). 
      # 
      my @date = ();        # Last mod time for each file
      my @size = ();        # Size of each file
      my @readyFiles;  # List of all files ready to copy (stable)
      my $triesLeft = ($cfg{src_retry_cnt} == 0) ? 0: $cfg{src_retry_cnt} - 1;

     TRIES: while ( $#readyFiles < 0 ) {
       
         doLog( $LOGLEVEL{debug2}, "Begin a try ($triesLeft tries left)..." );

	 #
	 # If using FTP, to start, open the FTP connection, login and
         # move to the correct directory
	 #
	 if ( $src{prot} =~ 'ftp' ) {
	    doLog( $LOGLEVEL{debug}, "Connecting via ftp..." );

            # Open FTP connection...
	    doLog( $LOGLEVEL{debug5}, "FTP opening session to $src{host}..." );
	    unless ( $ftp = Net::FTP->new( $src{host}, Debug=>0 ) ) {
	       doLog( $LOGLEVEL{error}, 
		      "Error opening FTP connection to $src{host}!" );
	       last TRIES;
	    }
	    
	    # Login
	    doLog( $LOGLEVEL{debug5}, "FTP logging in as $src{user}..." );
	    unless( $ftp->login( $src{user}, $src{auth} ) ) {
	       doLog( $LOGLEVEL{error}, 
		      "Error logging into " . $src{host} . "!" );
	       last TRIES;
	    }

	    # Set file xfer mode (ascii/binary) based on what was specified
	    if ( $src{prot} =~ 'ftp\((asc|bin)\)' ) {	
		$src{mode} = $1;
	    } else {
		$src{mode} = $feedDef{ftp_mode};
	    }
	    doLog( $LOGLEVEL{debug5}, "FTP setting xfer mode to $src{mode}" );
	    if ( $src{mode} eq 'asc' ) {
	       unless( $ftp->ascii() ) {
		   doLog( $LOGLEVEL{error}, "Error setting xfer mode!" );;
		   last TRIES;
	       }
	    } else { # else binary { 
		unless( $ftp->binary() ) {
		   doLog( $LOGLEVEL{error}, "Error setting xfer mode!" );;
		   last TRIES;
	       } 
	    } # else
	    
	    # FTP 'cd' to source directory...
	    if ( (defined $src{path}) && ($src{path} ne '') ) { 
		doLog( $LOGLEVEL{debug5}, "FTP cd to $src{path}" );
	       unless ( $ftp->cwd( $src{path} ) ) {
		  doLog( $LOGLEVEL{error}, "FTP 'cd' failed!" );
		  last TRIES;
	       }
	    } # if

	    doLog( $LOGLEVEL{debug4}, "FTP connected..." );

	 } # if ftp


	 #
	 # Within each "try", we need to make sure the file is ready (not
	 # still being updated).  So we check the size/date twice (with a
	 # 'src_ready_int' delay inbetween) and make sure we get the same
	 # list of files and same size/date both times.  This is done via a
	 # "full" directory listing. The name/date/size is also saved in case
	 # we are checking for duplicate files (files sent before) via name,
	 # last mod date, or size. 
	 #
	 my @files;       # The final list of all files found
	 my $last = 2;    # Always making 2 passes
        CHK_TWICE: for( my $i=1; $i <= $last; $i++ ) {

	    doLog( $LOGLEVEL{debug2}, 
		   "Getting dir listing (pass $i of $last)..." );

	    # Wait (sleep) for the "ready" interval (except on very first pass)
	    if ( $i > 1 ) {
		doLog( $LOGLEVEL{debug3}, "Sleeping for " 
		       . $cfg{src_ready_int} 
		       . " seconds before 2nd dir listing" );
		sleep $cfg{src_ready_int};
	    }

	    my @dirRes;  # holds result of dir cmd
	    
	    #
	    # Get dir listing via FTP...
	    #
	    if ( $src{prot} =~ 'ftp' ) {
		
		doLog( $LOGLEVEL{debug3}, 
		       "Gettting dir list via FTP..." );
	
		# Capture FTP 'dir' (long 'ls')  file listing...
		@dirRes = $ftp->dir( $src{files} );
		if ( !(@dirRes) || ($#dirRes == -1) ) {
		    doLog( $LOGLEVEL{warn},
			   "FTP 'dir' failed! (no files?)" );
		    # No files found so skip 2nd pass
		    last CHK_TWICE;
		}
		# Get file size & last mod dates for each file
		my $file;
		for my $line (@dirRes) {
		    # Skip error msgs...
		    next if (($line =~ /No such file/) || ($line =~ /^$/));

		    # Parse the actual filename from the directory listing
		    # (output differs by O/S type) 
		    doLog( $LOGLEVEL{debug5}, "Line: $line");
		    my @line = split /\s+/, $line;
		    if ( $src{os} =~ '(unix|macos)' ) {
			# Filename is last item on line
			$file = $line[$#line];
		    } elsif ( $src{os} eq 'vm' ) {
                        # Filename/type are first two fields
			$file = $line[0] . "." . $line[1];
		    } else {
			# Else filename is first item in line
			$file = $line[1];
		    }
		    
		    doLog( $LOGLEVEL{debug4}, "Processing file: $file" );

		    # Get last mod date/time.  Note: VM does not support mdtm 
                    # so parse date/time from the directory listing
		    if ( $src{os} eq 'vm' ) {
			$date[$i]{$file} = $line[6] . ":" . $line[7];
			$size[$i]{$file} = $line[4] . "." . $line[5];
		    } else {

		       # Get last mod time (if needed)
		       if ( ($cfg{src_ready} =~ 'date') 
			    || ($cfg{src_dup_chk} =~ 'date') ) {
			  unless( defined($date[$i]{$file} 
					  = $ftp->mdtm($file)) ) {
			    doLog( $LOGLEVEL{error}, 
				   "Cannot get file last mod time for '"
				   . $file . "' from ftp:"
				   . $src{host} . "!" );
			  } # unless
		       } else {
		           # Timestamp not needed so set to blank
			   $date[$i]{$file} = "";
		       }

		       # Get file size (if needed)
		       if ( ($cfg{src_ready} =~ 'size') 
			    || ($cfg{src_dup_chk} =~ 'size') ) { 
			  unless( defined ($size[$i]{$file} 
					   = $ftp->size($file)) ) {
			      doLog( $LOGLEVEL{error}, 
				     "Cannot get file size from ftp:"
				     . $src{host} . "!" );
			  }
		       } else {
			   # Size not needed so set to blank
			   $size[$i]{$file} = "";
		       }
		    } # else not 'vm'

		    # Log that we found a file...
		    doLog( $LOGLEVEL{debug3},
			   "Found file:" . $file . "(size=" . 
			   $size[$i]{$file} . ",date=" . $date[$i]{$file} 
			   . ")" );

		    # Save the filename in the list of found files (but only 
		    # on the first pass)
		    push @files, $file
			unless ($i == 2);
		    
		} # for each file
	    #
	    # Else get dir listing via SSH...
	    #
	    } elsif ( $src{prot} eq 'ssh' ) {
		
		doLog( $LOGLEVEL{debug3}, 
		       "Getting dir list via SSH..." );

		# Build the SSH command to get a dir listing...
		#
		my $cmd = $SSH . $sshOpt . " -i $keysDir/$keyFile" . " " 
		    . $src{user} . "@" . $src{host} . " '" 
		    . $LS{$src{os}} . " " . $src{path};

		# For unix, add a trailing '/' if missing. Then add filespec
		$cmd .= '/'
		    if ( ($src{os} eq 'unix') && ($src{path} !~ '/$') );

		$cmd .= $src{files}; 

                # If VMS, add a ';' if missing to get only the latest version
                # of the file.  Then close string.
		$cmd .= ';'           
		    if (($src{os} eq 'vms') && ($cmd !~ ';')); 
		$cmd .= "'";  

		# Log the SSH command being run
		doLog( $LOGLEVEL{debug}, "$cmd" );
		
		# Run the SSH command to get a dir listing
		my $res = `$cmd`;
		if ( $? != 0 ) {
		    doLog( $LOGLEVEL{warn},  "Error (" . ($?>>8) 
			   . ") getting SSH dir listing! (no files?)" );
		    # No files found so skip 2nd pass
		    last CHK_TWICE;
		}
		
		# Parse file name/size/last mod time from the output lines
		#
		foreach my $line (split /^/, $res) {

		    my ($file,$size,$date);

		    # Skip blank lines ###and 'total' line
		    next 
		      if ( $line =~ /^\w?$/ );
		    ###next if ( $line =~ m/^total/xo );
		    
		    # If O/S is VMS, skip any lines w/o a semi-colon (file 
		    # version) or the "file not found" error
		    next 
		      if ( ($src{os} eq 'vms') 
			 && (($line !~ ';') || ($line =~ 'DIRECT-E-OPENIN')) );

		    # Parse output (varies by O/S type)
		    my @line = split /\s+/, $line;
		    if ( $src{os} eq 'unix' ) {
			$file = $line[8];
			$size = $line[4];
			$date = $line[5] . $line[6] . $line[7];
		    } elsif ( $src{os} eq 'vms' ) {
			$file = $line[0];
			$size = $line[1];
			$date = $line[2] . ":" . $line[3];
		    } elsif ( $src{os} eq 'macos' ) {
			$file = $line[8];
			$size = $line[4];
			$date = $line[5] . $line[6] . $line[7];
		    } elsif ( $src{os} eq 'vm' ) {
			$file = $line[8];
			$size = $line[2]; ##???
			$date = $line[5] . $line[6] . $line[7]; ##???
		    } elsif ( $src{os} eq 'mswin' ) {
			$file = $line[8];
			$size = $line[2]; ##???
			$date = $line[3] . $line[4]; ##???
		    };

		    # Skip line if file is a directory
		    if ( (($src{os} eq 'vms') && ($file =~ '.DIR;'))
			 || (($src{os} =~ 'unix|macos') 
			     && ($line =~ '^d')) ) {
			doLog( $LOGLEVEL{warn}, 
			       "Found directory not file ($file). Skipping." );
			next;
		    } # if 
			 

		    # For unix/Mac, strip the path/directory off the file 
		    if ( ($src{os} =~ "unix|macos") 
			&& ($file =~ /$src{path}(.+)/) ) {
		       $file = $1;
		    } else {
		       # Else for VMS, strip version and convert to lowercase
		       $file =~ tr/A-Z/a-z/;
		       $file =~ s/;.+//;
		    }
		    
		    doLog( $LOGLEVEL{debug3}, 
			   "SSH::Found file:" . $file . "(size=" . 
			   $size . ",date=" . $date . ")" );
		    
		    # Save size/last mod time from this pass for later 
		    # comparison
		    $size[$i]{$file} = $size;
		    $date[$i]{$file} = $date;

		    # Save the file in the list of found files (but only on 
		    # first pass)
		    push @files, $file
			unless ($i == 2);
	    
		} # foreach file
	
	    # 
	    # Else get "local" dir listing...
	    #
	    } else { 
		doLog( $LOGLEVEL{debug3}, "Getting local dir list..." );
	
		# Make sure directory exists
		unless ( -d $src{path} ) {
		    doLog( $LOGLEVEL{error},
			   "Source directory not found ($src{path})!" );
		    last TRIES;
		}
	
		# Build the 'ls' command and execute it
		my $cmd = "cd $src{path}; ls -d $src{files}";
		doLog( $LOGLEVEL{debug}, $cmd );
		my $res = `$cmd`;
		if ( $? != 0 ) {
		    doLog( $LOGLEVEL{warn}, "Error (" . ($?>>8) 
			 . ") getting local directory listing! (no files?)" );
		    # No files found so skip 2nd pass
		    last CHK_TWICE;
		}
	
		# For each line/file found, save the filename and get the 
		# file size and last modify date
		#
		foreach my $file (split /\s+/m, $res) {

		    # Skip if a directory
		    unless( -f "$src{path}/$file" ) {
			doLog( $LOGLEVEL{warn}, 
			       "$file is not a file.  Skipping..." );
			next;
		    }

		    ($size[$i]{$file}, $date[$i]{$file}) 
			= (stat($src{path} . "/" . $file ))[7,9];
		    
		    doLog( $LOGLEVEL{debug3},
			   "Local::Found file:" . $file . "(size=" . 
			   $size[$i]{$file} . ",date=" . $date[$i]{$file} 
			   . ")" );
		    push @files, $file
			unless ($i == 2);
	    
		}
		
	    } # else a local copy

	    # If no files found, skip the 2nd pass
	    if ( $#files < 0) {
		doLog( $LOGLEVEL{warn}, "No files found, skipping 2nd pass" );
		last CHK_TWICE;
	    }
	
         } # for CHK_TWICE

         #
         # Walk through the list of files found checking for a match in the
         # history file (if duplicate checking is configured) and for file 
         # readiness using the configured method (size/date/sum not
         # changing, control files exist, lock files not found, etc)
         #
	 my $ctlFilesFound = 0;
	 my $ctlFileCnt;
	CHKFILE: foreach my $file (@files) {
	    
	    # If we are supposed to check for duplicates (have we copied this
	    # file before?) by name or size in the history file, do so now, 
	    # skipping the file if a match is found
	    if ( defined $cfg{src_dup_chk} ) {
		doLog( $LOGLEVEL{debug3}, 
		       "Checking for $file in history log..." );

		# Check if file found in history file...		
		my $res = `grep ": $file" $histFile | tail -1` ;
                # Return status always 0 so check for filename in string
		if ( $res =~ /$file/  ) {
		    doLog( $LOGLEVEL{debug}, "Found $file in history log" );

		    # Parse size from history file entry
		    my $sizeh = (split /\s+/,$res)[3];
		    chomp( $sizeh );

		    # Compare the match using the dup check methond configured
		    if ( $cfg{src_dup_chk} eq 'name' ) {
		       doLog( $LOGLEVEL{debug},
			      "    ...found NAME match. Skipping..." );
		       next CHKFILE;
		    } elsif ( ($cfg{src_dup_chk} eq 'size') 
			    && ($size[1]{$file} eq $sizeh) ) {
		       doLog( $LOGLEVEL{debug},
		              "    ...found SIZE match. Skipping..." );
		       next CHKFILE;
		    }	       
		} else {  # else not found in history file
 		   doLog( $LOGLEVEL{debug5}, "   ... file NOT found." );
		} # if found in history file 
		    
	    } else { # else not checking for dups
	       doLog( $LOGLEVEL{debug5}, "Not checking for dups." );
	    } # if checking for duplicates
	 
	    # If two passes were made to look for files, make sure the file 
	    # was found on both passes
	    if ( ($last == 2) 
		 && !(exists $size[1]{$file} && exists $size[2]{$file})
		 && !(exists $date[1]{$file} && exists $date[2]{$file})) {
		doLog( $LOGLEVEL{warn}, 
		       $file . " not found on both passes.  Skipping." );
		next CHKFILE;
	    }

	    # Check for file readiness...
	    #
	    # If readiness is based on date/size, compare date/size from
	    # both passes...
	    if (( ($cfg{src_ready} eq 'date') 
		  && ($date[1]{$file} != $date[2]{$file}) )
		# Or sizes don't match...
		|| ( ($cfg{src_ready} eq 'size') 
		     && ($size[1]{$file} != $size[2]{$file}) )) {
		doLog( $LOGLEVEL{warn}, 
		       "Size or date does not match for $file. Skipping." );
		next CHKFILE;

	    # Else if readiness is based on a lock file...
	    } elsif ( $cfg{src_ready} =~ 'lck:(.*)' ) {
		my $lockFileSpec = perlregexp($1);

		doLog( $LOGLEVEL{debug3}, "Checking for lock file..." );

		# If this file matches the lock file, clear the ready list 
		# and try again later
		if ( $file =~ /$lockFileSpec/ ) {
		    doLog( $LOGLEVEL{info}, 
			   "Lock file found ($file). Try again later..." );
		    undef @readyFiles;
		    next TRIES;
		 } # if

	    # Else if readiness based on control files...
	    } elsif ( $cfg{src_ready} =~ 'ctl:(\d+):(.*)' ) { 
		$ctlFileCnt = $1;
		my $ctlFileSpec = perlregexp($2);

		# If this is a control file, count it.
		$ctlFilesFound++
		    if ( $file =~ /$ctlFileSpec/ );

		doLog( $LOGLEVEL{debug3}, 
		       "Checking for control file(s) (found " . $ctlFilesFound
		       . " of " . $ctlFileCnt . ")..." );

	    } # if file readiness checking
	    
            # The file is ready so add it to the list of ready files.
	    push @readyFiles, $file;		  

         } # foreach CHKFILE

	 # If using control files for file readiness and not all control 
         # files were found try again (empty the ready file list)
	 if ( ($cfg{src_ready} =~ 'ctl') && ($ctlFilesFound < $ctlFileCnt) ) {
	     doLog( $LOGLEVEL{info}, 
		    "Not all control files found. Try again later..." );
	     undef @readyFiles;
	     next TRIES;
	 } # if

     } continue { # while TRIES (no ready files found)
          
	 doLog( $LOGLEVEL{debug3}, "Try done $triesLeft tries left..." );

	 # Decrement try count. Any tries left?
	 $triesLeft--;   # decrement try counter
	 last TRIES if ( $triesLeft < 0 );

	 # If no files ready, wait for the configured ready interval before 
         # trying again...
	 if ( $#readyFiles < 0 ) {
	     doLog( $LOGLEVEL{debug}, 
		    "No files ready. Sleeping " . $cfg{src_retry_int} . 
		    " seconds before trying again" );
	     sleep $cfg{src_retry_int};
	 }
	 
     } # while TRIES continue

      # We've used up all tries. If no ready files were found, just skip to 
      # next source
      if ( $#readyFiles < 0 ) {
	  doLog( $LOGLEVEL{debug}, 
		 "No files ready to process for this source!" );
	  next SOURCE;
      }
 
      #
      # Otherwise copy the ready files to the local working directory.
      #
      # If the configured "source ready check" is 'copy', copy the files twice
      # (waiting between copies for the the configured "source ready interval")
      # so we can compare sizes or last mod times.
      #
      doLog( $LOGLEVEL{debug}, "Retrieving files..." );

      my @sum = ();
      my $last = ( $cfg{src_ready} =~ 'copy' ) ? 2 : 1;
    COPY_TWICE: for( my $i=1; $i <= $last; $i++ ) {
   
	# For each file...
       COPYFILE: foreach my $j (0..$#readyFiles) {
	   my $file = $readyFiles[$j];

	   doLog( $LOGLEVEL{debug3}, 
		  "Copying (pass $i of $last) $file to $inDir." ); 
	   my ($cmd, $keyFile);

	   # FTP...
	   if ( $src{prot} =~ 'ftp' ) {
	       doLog( $LOGLEVEL{debug}, 
		      "FTP get " . $file  );
	      unless( $ftp->get($file,$inDir . "/" . $file) ) {
		  doLog( $LOGLEVEL{error}, 
		         "Error FTP getting file ($file)!" );
		  next COPYFILE;
	      }
   
	   # SSH...
	   } elsif ( $src{prot} eq 'ssh' ) {

	      # If VMS strip version from file and convert to lower case
	      if ( $src{os} eq 'vms' ) {
		  $file = $1 
		      if ( $file =~ /(.+);(\d?)/ );
		  $file =~ tr/A-Z/a-z/;
	      }              

	      # Build the SCP cmd and run it...
	      $keyFile = $keysDir . "/" . $src{auth};

	      $cmd = $SCP . $scpOpt . " -i " . $keyFile . " '" 
		  . $src{user} . "@"  . $src{host} . ":";
	      
	      # If path provided/exists, add it. For VMS, add original 
	      # (unconverted) path
	      if ( exists($src{path}) ) {
		  if ( $src{os} eq 'vms' ) {
		      $cmd .= $src{path_orig};
		  } else {
		      $cmd .= $src{path};
		  }
	      }
	      # Add trailing '/' if missing from path
	      $cmd .= '/'
		  if ($cmd !~ /\/$/);
	      # Add filename and destination dir
	      $cmd .= $file . "' " . $inDir;
	      
	      doLog( $LOGLEVEL{debug}, $cmd );

	      # Run the command
	      print `$cmd`;
	      if ( $? != 0 ) {
	         doLog( $LOGLEVEL{error}, 
		        "Error (" . ($?>>8) . ") SCPing file ($file)!" );
		 next COPYFILE;
	      } # if

           # Local copy...
	   } else {
	      $cmd = "cp -p ";
	      $cmd .=  (exists $src{path}) ? $src{path} : "";
	      $cmd .= "/" . $file . " " . $inDir;
	      doLog( $LOGLEVEL{debug}, $cmd );

	      # Run the command
	      print `$cmd`;
	      if ( $? != 0 ) {
		 doLog( $LOGLEVEL{error}, "Error (" . ($?>>8) 
			. ") copying local file ($file)!" ); 
		 next COPYFILE;
	      } 
	   } # else

	   #
	   # Capture a check sum of the local file
	   #
	   $sum[$i]{$file}  = (split /\s+/,`$CKSUM $inDir/$file`)[0];
	   if ( $? != 0 ) {
	      doLog( $LOGLEVEL{error}, 
		     "Error (" . ($?>>8) . ") getting check sum ($file)!" ); 
	      # This is not good but not a showstopper so just continue
	   }
	   chomp( $sum[$i]{$file} );

	   # If we are supposed to check for duplicates via check sum
           # check now and skip the file (delete the local copy) if a 
           # match is found
	   if ( (defined $cfg{src_dup_chk}) && ($cfg{src_dup_chk} eq 'sum')) {
	      my $res = `grep ": $file" $histFile | tail -1`;
	      if ( $res =~ /$file/ ) {
		  # Found in history file...
		  my $sumh = (split /\s+/, $res)[2];
		  chomp($sumh);
		  # Compare check sum with history entry...
		  if ( ($cfg{src_dup_chk} eq 'sum') 
		      && ($sum[$i]{$file} == $sumh) ) {
		      doLog( $LOGLEVEL{warn}, 
			     "Found match for $file in history. Skipping..." );
		      # Delete the file from the array and working directory
		      delete $readyFiles[$j];
		      my $res = unlink "$inDir/$file";
		      doLog( $LOGLEVEL{error},
			     "Error deleting incoming file ($file)" )
			  if ($res != 1);
		      next COPYFILE;
		  }
	      } # if found in history file
	   } # if checking for dups by check sum

	   #
	   # If we are on the last pass, delete the source files if so
           # configured 
	   #
	   if ( ($src{del} =~ /y/) && ($i = $last) ) {
	      # FTP...
	      if ( $src{prot} =~ 'ftp' ) {
		 unless( $ftp->delete($file) ) {
		     doLog( $LOGLEVEL{error}, 
		       "Error deleting source file ($file) from FTP server" );
		     next COPYFILE;
		 }
	      # SSH...
	      } elsif ( $src{prot} eq 'ssh' ) {
		  $cmd = $SSH . $sshOpt . " -i " . $keyFile . " " 
		        . $src{user} . "@"  . $src{host} . " '" 
			. $RM{$src{os}} . " ";
		  $cmd .= (exists $src{path}) ? $src{path} : "";
		  $cmd .= $file . ";'";
		  doLog( $LOGLEVEL{debug}, $cmd );

		  # Run the command
		  print `$cmd`;
		  if ( $? != 0 ) {
		      doLog( $LOGLEVEL{error}, "Error (" . ($?>>8) 
			     . ") deleting local source file ($file)!" ); 
		      next COPYFILE;
		  } 
	      # Local...
	      } elsif ( $src{prot} eq 'local' ) {
		  $cmd =~ s/cp -p/rm -f/;
		  doLog( $LOGLEVEL{debug}, $cmd );
		  
		  # Run the command
		  print `$cmd`;
		  if ( $? != 0 ) {
		      doLog( $LOGLEVEL{error}, "Error (" . ($?>>8) 
			     . ") deleting local source file ($file)!" ); 
		      next COPYFILE;
		  } 
	      } # else local

	   } # if deleting source files

	} # foreach file

        # If not the last copy, wait for the configured ready interval before
        # looping back for the 2nd copy
	if ( $i < $last ) {
	    doLog( $LOGLEVEL{debug3}, "Sleeping " . $cfg{src_ready_int} 
		   . " seconds before 2nd copy" );
	    sleep $cfg{src_ready_int};
	}


     } # for COPY_TWICE

     # Close the FTP connection
     if ( $src{prot} =~ 'ftp' ) {
	 $ftp->quit();
     }

     # If files were copied twice, compare sizes (cksum) to make sure the file
     # is not changing 
     if ( $last == 2 ) {
	doLog( $LOGLEVEL{debug2}, "Comparing sizes of files copied twice..." );

	# For each file...
	foreach my $i (0..$#readyFiles) {
	   my $file = $readyFiles[$i];

	   # If files differ, delete file from list and working directory
	   if ( $sum[1]{$file} != $sum[2]{$file} ) {
	       doLog( $LOGLEVEL{warn}, "Files differ (sum=" . $sum[1]{$file}
		      . " / " . $sum[2]{$file} . "). Skipping " . $file );
	       delete $readyFiles[$i];
	       my $res = unlink "$inDir/$file";
	       doLog( $LOGLEVEL{error},
		      "Error deleting incoming file ($file)" )
		   if ($res != 1);
	   } # if
	   doLog( $LOGLEVEL{debug5}, "File sizes match. $file is ready" );
        } # foreach file
     } # if copied twice

     # Append the list of ready files to the master list and save the last
     # mod date, size and check sum for later
      foreach my $file (@readyFiles) {
	  push @inFiles, $file;

	  $inSum{$file} = $sum[1]{$file};
	  $inDate{$file} = $date[1]{$file};
	  $inSize{$file} = $size[1]{$file};
      } # foreach


   } # foreach src line

   doLog( $LOGLEVEL{debug4}, "Out doPullFiles..." );

} # sub doPullFiles


#
# ------------------------------------------------------------------------
#
# Unpack/Uncompress incoming files. In the order specified in the src_unpack
# feed control file option, "unpack" the files that were received in the 
# supported methods (untar, unzip, gunzip, uncompress, decrypt /w PGP/GPG).  
# Where appropriate the original files are deleted after the unpack step is 
# finished.
#

sub doUnpack {

   doLog( $LOGLEVEL{debug4}, "In doUnpack..." );

   # Start in the incoming directory 
   chdir $inDir;

   # Unpack in the order specified
   my $cmd;
  TASK: foreach my $task (split /:/, $cfg{src_unpack}) {

      # Log the unpack task type but not any passwords etc
      doLog( $LOGLEVEL{debug}, "Unpacking via "
	     . (($task =~ '(.+)=(.+)')? $1 : $task) . "...") ;

      # Get a list of files to be processed (or return if none found)
      my @files = glob("*");
      if ( $#files < 0 ) {
	  doLog( $LOGLEVEL{error}, "No files to process!" );
	  next TASK;
      }

      # If uncompressing/untaring...
      if ($task =~ '(b|g)?unzip|uncompress|untar') {

	 # Unpack/Uncompress each file
	 foreach my $file (@files) {

	    # For non-archival compressed files (bzip,gzip,compress) if the
            # filename does not already end in the expected extension 
	    # (.bz2/.gz/.z) append to the filename to avoid overwriting 
            # itself during decompression
	    my $ext = "." . $EXT{$task};
	    if ( ($task =~ 'bunzip|gunzup|uncompress') 
		 && ($file !~ /$ext$/i) ) {
		rename $file, $file.$ext;
		$file .= $ext ;
	    }
		    

	    if ($task eq 'bunzip') {
	       $cmd = "$BUNZIP $file";
	    } elsif ($task eq 'gunzip') {
	       $cmd = "$GUNZIP $file";
	    } elsif ($task eq 'unzip') {
	       $cmd = "$UNZIP $file";
	    } elsif ($task eq 'uncompress') {
	       $cmd = "$UNCOMPRESS $file";
	    } elsif ($task eq 'untar') {
	       $cmd = "tar -xf $file";
	    }
	    # Execute cmd and check for an log any errors
	    ###print "cmd=$cmd\n"; #XXX
	    print `$cmd`;
	    if ( $? != 0 ) {
	       doLog( $LOGLEVEL{error},	
		    "Error (" . ($?>>8) . ") unpacking ($cmd) file ($file)" );
	       return 0;
	    }
	 } # foreach file

      # Else if decrypting...
      } elsif ($task =~ '(gpg|pgp)-(pswd|pfile)=([^/:=]+)(/sign)?(/bin)?') {
	 my $task = $1;
	 my $type=$2;
	 my $key=$3;
	 my ($binary,$sign);
	 if ( $key =~ '(.+)/(sign|bin)(/bin)?' ) {
	     $sign=$2;
	     $binary=$3;
	 }
	 my $pphrase;
	 # If type is user, make sure passphrase file is readable
	 if ( $type eq 'pfile' ) {
	     unless( $pphrase = `cat $keysDir/$key` ) {
		 doLog( $LOGLEVEL{error},
			"Cannot read passphrase file ($keysDir/$key)" );
		 return 0;
	     }
	     chomp $pphrase;
	 } # if
	 
	 # Set ascii/text decrypt flag if needed
	 my $ascOpt = ($binary =~ '/bin')? "" : "-t";

	 # Decrypt each file...
	 foreach my $file (@files) {

	    # If the filename does not end in the expected extension 
	    # (.pgp/.gpg/.asc) append one to the filename to avoid 
	    # overwriting itself during decryption
	    #
	    my $ext = "." . $EXT{$task};
	    if ( $file !~ /($ext|.asc)$/i ) {
		doLog( $LOGLEVEL{debug5}, "Adding " . $ext
		       . " extension to " . $file );
		rename $file, $file.$ext
		    or doLog( $LOGLEVEL{error}, "Error renaming " . $file
			      . " to add " . $ext . " extension!" );
		$file .= $ext;
	    }
		     
	    # GPG...
	    if ( $task =~ 'gpg' ) {
	       # Assuming symmetric key encryption as that's all GPG
               # supports programatically...
	       $cmd = "echo \"$pphrase\" | " 
		   . "$GPG --passphrase-fd 0 $gpgOpt $ascOpt $file";

	       # PGP...
	    } elsif ( $task =~ 'pgp' ) {
	       if ( $type eq 'pfile' ) {
		   $cmd = "export PGPPASS=\"$pphrase\"; " 
		       . "$PGP $pgpOpt $ascOpt $file";
	       } else {  # $type eq 'pswd'
	           $cmd = "export PGPPASS=\"$key\"; " 
		       . "$PGP $pgpOpt $ascOpt $file";
	       } # else
	    } # elsif

	    # Execute cmd and check cmd line results. If decrypt failed...
	    ###print "cmd=$cmd\n"; #XXX
	    print `$cmd`;

	    # Check return status. (0=good, 1=no/bad signature, >0=error)
            # System call error returned in high-order byte
	    my $ret = $? >> 8;
	    if ($ret > 1) {  
		doLog( $LOGLEVEL{error}, 
		       "Error ($ret) decrypting file ($file)!" );
		# Remove the file from the master incoming files list as it 
		# may be accidentally not encrypted file we don't want to 
		# archive it in that case
		for( my $i=0; $i<$#inFiles; $i++ ) {
		   if ( $inFiles[$i] == $file ) {
		       delete $inFiles[$i];
		       last;
		   } #if
		} # for
	    return 0;
	    } # if error returned

	    # If signature was expected but bad/not found, log an error
	    doLog( $LOGLEVEL{error}, "Bad (or no) signature found!" )
		if (($ret == 1) && ($sign =~ 'sign'));

	 } # foreach file

      } else {
	 doLog( $LOGLEVEL{error}, "Bad unpack task ($task)!" );
	 return 0;
      }

      # Delete all the original files.  
      unlink @files;

   } # foreach task

   doLog( $LOGLEVEL{debug4}, "Out doUnpack..." );

###   return 1;

} # sub doUnpack


#
# ------------------------------------------------------------------------
#
# Pack/Compress outgoing files.  In the order specified in the dst_pack
# option in the feed control file, "pack" the files in the various supported 
# methods (tar, zip, gzip, compress, encrypt w/ PGP/GPG, chmod, 
# upper/lowercase filename).  Where appropriate, the original files are 
# deleted afterwards.
#

sub doPack {

   doLog( $LOGLEVEL{debug4}, "In doPack..." );

   # Start in the incoming directory 
   chdir $inDir or doErrorExit( "doPack: Cannot chdir to $inDir!" );

   # Pack files in the order specified
   my $cmd;
  TASK2: foreach my $task (split /:/, $cfg{dst_pack}) {

      doLog( $LOGLEVEL{debug}, "Packing via "
	     . (($task =~ '(.+)=(.+)')? $1 : $task) . "...") ;

      # Get a list of files to be processed, flag error and exit if none found
      my @files = glob("*");
      if ( $#files < 0 ) {
	  doLog( $LOGLEVEL{error}, "No files for this source to process!" );
	  next;
      }


      # If compressing...
      if ($task =~ '(b|g)zip|compress') {

	 # Pack/Compress each file
	 foreach my $file (@files) {
	    if ($task eq 'bzip') {
	       $cmd = "$BZIP $file";
	    } elsif ($task eq 'gzip') {
	       $cmd = "$GZIP $file";
	    } elsif ($task eq 'zip') {
	       $cmd = "$ZIP $file";
	    } elsif ($task eq 'compress') {
	       $cmd = "$COMPRESS $file";
	    } elsif ($task eq 'tar') {
	       $cmd = "tar -xf $file";
	    }

	    # Execute cmd and check for an log any errors
            print `$cmd`;
	    doLog( $LOGLEVEL{error},	
		   "Error (" . ($?>>8) . ") packing/compressing file ($file)" )
		if ($? != 0);

	} # foreach file

      # Else if tarring...
      } elsif ($task =~ 'tar=(.+)') {
	  my $tarFile = $tmpDir . "/" . $1;
	  # Tar up all files in incoming dir
	  print `tar cf $tarFile .`;
	  if ($? != 0) {
	      doLog( $LOGLEVEL{error}, "Error (" . ($?>>8) . 
		     ")tar'ng outgoing datafiles!" );
	      return 0;
	  }
	  # Delete all files (that are tarred)
	  my $res = unlink @files;
	  if (($res-1) != $#files) {
	     doLog( $LOGLEVEL{error},
		    "Error ($res) deleting all $#files tar'd files!" );
	     return 0;
	 }
	  # Move tar file back to incoming dir for next pass
	  `mv $tarFile .`;
	  if ($? != 0) {
	      doLog( $LOGLEVEL{error}, "Error (" . ($?>>8) 
		             . ") moving tarfile back to incoming dir!" );
	      return 0;
	  }

      # Else if encrypting...
      } elsif ($task =~ '(gpg|pgp)-(user|pswd)=(.+)') {
	 my $type = $2;
	 my $key = $3;

	 # Pick off option switches as expected from right to left
	 my $binOpt = "";
	 my $armorOpt = "";
	 my $rmExt = 'n';
	 ###print "XXX task: $task\n1=$1,type=$2,key=$3\n"; #XXX
	 if ($key =~ '(.+)(/rmext)') {   # remove file ext from encrypted file
	     $key = $1;
	     $rmExt = 'y';
	     ###print "XXX rmext: key=$1,2=$2\n"; #XXX
	     doLog( $LOGLEVEL{debug3}, "   Removing file extension!" );
	 }	 
	 if ($key =~ '(.+)(/asc)') {   # ascii armor the output file
	     $key = $1;
	     $armorOpt = "-a";
	     ###print "XXX asc key: $key\n1=$1,2=$2\n"; #XXX
	     doLog( $LOGLEVEL{debug3}, "   Using ASCII armor!" );
	 }
	 if ($key =~ '(.+)(/bin)') {   # treat input file as binary?
	     $key = $1;
	     $binOpt = "-t";
	     ###print "XXX bin key: $key\n1=$1,2=$2\n"; #XXX
	     doLog( $LOGLEVEL{debug3}, "   Encrypting as binary file!" );
	 }
	 my ($sign, $ppfile);
	 my $pphrase;
	 if ( $key =~ '(.+)/sign=(.+)/pfile=(.+)' ) {
	     $key = $1;
	     $sign = $2;
	     $ppfile = $keysDir . "/" . $3;
	     doLog( $LOGLEVEL{debug3}, "   Signing file." );
	     ###print "XXX key: $key\n1=$1,2=$2,3=$3\n"; #XXX

	     # Make sure passphrase file exists and is readable
	     unless( $pphrase = `cat $ppfile` ) {
		 doLog( $LOGLEVEL{error},
			"Cannot read passphrase file ($ppfile)" );
		 return 0;
	     }
	     chomp $pphrase;

	 } # if signing 

	 # Output file name if /rmext (remove file extension) is specified
	 my $outFile = ""; 

	 # Encrypt each file...
	 foreach my $file (@files) {

	    # If removing the file extension...
	     if ( $rmExt eq 'y' ) {
		$outFile = $file;
		my $ext;
		if ( $armorOpt eq "" ) {  # using ASCI armor?
		    $ext = ($task =~ 'pgp')?'pgp':'gpg';
		} else { 
		    $ext = 'asc';
		}
		$file =~ /(.+)\.(.){1,}/;
		$outFile = "-o $1.$ext";
	    }

            # GPG...
	    if ( $task =~ 'gpg' ) {
	       my $opts = "$gpgOpt $ascOpt $armorOpt $outFile"; 

               # Assuming symmetric key encryption as that's all GPG
               # supports programatically...
	       if ( defined $sign ) {
		  $cmd = "echo \"$pphrase\" | "
                        . "$GPG --passphrase-fd 0 -es $opts" .
			" -r $key -u $sign $file";
	       } else {
		  $cmd = "$GPG -r $key -e $opts $file";
	       }

	       # Execute cmd and check cmd line results. 
	       ###print "XXX cmd=$cmd\n"; #XXX
	       print `$cmd`;
	       if ($? != 0) {
		   doLog( $LOGLEVEL{error}, "Error (" . (($?>>8)) 
			  . ") GPG encrypting file ($file)!" ); 
		return 0;
	       } # if error

	       # Erase the original file
	       unlink "$inDir/$file";

            # PGP...
	    } else { 
	       my $opts = "$pgpOpt $ascOpt $armorOpt $outFile"; 

               # Secret/Password encryption...
	       if ($type eq 'pswd' ) {
		  # Cannot sign and password encrypt (req 2 passwords)
		  if ( $task =~ '/sign' ) {
		     $cmd = "export PGPPASS=\"$pphrase\"; "
			 . "$PGP -cws $sign $opts $file";
		  } else {
		     $cmd = "export PGPPASS=\"$key\"; " 
			 . "$PGP -cw $opts $file";
		  }
               # Public key encryption...
	      } elsif ( $type eq 'user' ) {
		  if ( $task =~ '/sign' ) {
		     $cmd = "export PGPPASS=\"$pphrase\"; "
			 . "$PGP -ews $opts $file $key -u $sign";
		  } else {
		     $cmd = "$PGP -ew $opts $file $key";
	          }
	      } # elsif

	      # Execute cmd and check cmd line results. 
	      ###print "XXX cmd=$cmd\n"; #XXX
	      print `$cmd`;
	      if ($? != 0) {
		 doLog( $LOGLEVEL{error}, "Error (" . (($?>>8)) 
			. ") PGP encrypting file ($file)!" ); 
		 return 0;
	      } # if error

	    } # else PGP 

	 } # foreach file

      } elsif ($task =~ '(upper|lower)') {

	 my $newCase = $1;
	 doLog( $LOGLEVEL{debug2}, "Changing file case to " . $newCase );

	 chdir $inDir;   # should already be here anyway?

	 # Rename each file, only if not already in the needed case
	 my $newName;
	 foreach my $file ( glob "*" ) {
	    $newName = ($newCase =~ /upper/i) ? uc($file) : lc($file);
	    if ( $file ne $newName ) {
	       doLog( $LOGLEVEL{debug5}, '  rename '. $file . ' ' . $newName );
	       rename $file, $newName
		   or doLog( $LOGLEVEL{error}, 
			     "Error renaming " . $file . " to " . $newName );
	    } # if 
         } # for each file

      } elsif ($task =~ 'chmod=(.+)') {

	 my $newMode = $1;
	 doLog( $LOGLEVEL{debug2}, "Changing file mod to " . $newMode );

	 chdir $inDir;   # should already be here anyway?

	 # Chmod each file...
	 my $res;
	 foreach my $file ( glob "*" ) {
	    doLog( $LOGLEVEL{debug5}, 
		   '  chmod '. $newMode . ' ' . $file );
	    $res = chmod oct($newMode), $file;
	    doLog( $LOGLEVEL{error}, "Error CHMODing file (" . $file. ")" )
		if ( $res != 1 );
         } # for each file

     } elsif ($task =~ 'timestamp=(.+)') {
	 doLog( $LOGLEVEL{debug2}, "Adding timestamp (fmt=$1) to filename" );
	 

	 # Get current time using specified format string.  Use YYYYMMDDHHMM
	 # if any error with supplied format
	 my $fmt = $1;
         my $now = `date "+$fmt"`
	     or $now = `date "+%Y%m%d%H%M`;
	 chomp $now;

	 # Rename file with timestamp string appended
	 foreach my $file ( glob "*" ) {
	     rename $file, $file.$now
		 or doLog( $LOGLEVEL{error},
			   "Error renaming " . $file . " to " . $newName );
	 } # for each file

     } else { 

	doLog( $LOGLEVEL{error}, "Bad packing task ($task)!" );
	return 0;

     } # end else (switch) on task

   } # foreach task

   doLog( $LOGLEVEL{debug4}, "Out doPack..." );

###   return 1;

} # sub doPack


#
# -----------------------------------------------------------------------
#
# Send/Push outgoing files to destination(s)
#

sub doPushFiles {

   doLog( $LOGLEVEL{debug4}, "In doPushFiles..." );

   # Get a list of files to be processed
   chdir $inDir
       or doLog( $LOGLEVEL{error}, "doPushFiles: cannot chdir" );;

   # Get a list of files to be processed, flag error and exit if none found
   my @files = glob("*");
   if ( $#files < 0 ) {
       doLog( $LOGLEVEL{error}, "No files to process!" );
       return 1;
   }


   # 
   # Multiple destinations are allowed.  For each one...
DEST: foreach my $dstLine ( @{ $cfg{dst} } ) {

      doLog( $LOGLEVEL{debug}, "Processing dest: $dstLine" );

      # Parse and validate the fields from the dst param value
      #    dst: <prot>:<os>:<host>:<user>:<auth>:<path>
      #         local:<path>
      my (%dst, $ftp, $keyFile);

      # Local or remote?
      if ( $dstLine =~ m/local:/io ) {
         # dest is local...
	 ($dst{prot}, $dst{path}) = split /:/, $dstLine;
	  
	 # Make sure a destination path is provided
	 unless( defined $dst{path} ) {
	    doLog( $LOGLEVEL{error}, 
	           "Bad datafeed destination (dstLine)!" );
	    next DEST;
	 }
      } else {
	 # source is remote...
	 ( $dst{prot}, $dst{os}, $dst{host}, $dst{user}, $dst{auth},
	   $dst{path} ) = split /:/, $dstLine;
	 # Make sure all required values are provided
	 unless( defined $dst{prot} and defined $dst{os} and defined $dst{host}
                 and defined $dst{user} and defined $dst{auth} ) {
	     doLog( $LOGLEVEL{error},"Bad datafeed destination ($dstLine)!" );
	     next DEST;
	 }
      } # else

      # Apply a default value for such missing optional fields. Optional 
      # fields that are not provided will have their keys defined in
      # in the 'src' hash, but will have 'undefined' values. 
      $dst{path} = $feedDef{path}
         unless ( defined( $dst{path} ) );
      
      # Parse the auth field
      $dst{auth} =~ '(pswd|key)=([^:/=]+)';
      $dst{auth} = $2;

      # Some fields are not case-sensitive so just translate all those 
      # to all lowercase for easier comparisons later 
      foreach my $p qw(prot os host) {
	 $dst{$p} =~ tr/A-Z/a-z/
	    if ( exists $dst{$p} ); 
      }
   
      # Check each field value against the expected format
      foreach my $p (keys %dst) {
	 if ( (exists $validValue{$p}) 
		&& ($dst{$p} !~ m/$validValue{$p}/) ) {
            doLog( $LOGLEVEL{error}, "Bad dest parameter (" . $p .") value ("
		   . $dst{$p} . ")!" );
	 }
      } # foreach field

      # Since VM paths have a colon (the field delimter), a '/' is used so
      # convert that '/' back to a ':'
      $dst{path} =~ s|/|:|
	  if ($dst{os} eq 'vm');

      #   
      # If using FTP, open the connection, login, and move to the correct 
      # directory.
      #
      if ( $dst{prot} =~ 'ftp' ) {
	 doLog( $LOGLEVEL{debug2}, "Connecting via ftp..." );
	  
	 # Open FTP connection...
	 unless ( $ftp = Net::FTP->new( $dst{host}, Debug=>0 ) ) {
	    doLog( $LOGLEVEL{error}, "Error (" . $ftp 
		   . ") opening FTP connection to " . $dst{host} . "!" );
	    next DEST;
	 }
	    
	 doLog( $LOGLEVEL{debug5}, "FTP session opened ..." );

	 # Login
	 doLog( $LOGLEVEL{debug5}, "FTP logging in ..." );
	 unless( $ftp->login( $dst{user}, $dst{auth} ) ) {
	    doLog( $LOGLEVEL{error}, 
		 "Error (" . ($?>>8) . ") logging into " . $dst{host} . "!" );
	    next DEST;
	 }

	 # Set file xfer mode (ascii/binary) based on what was specified
	 $dst{prot} =~ 'ftp\((\w{3})\)';
	 $dst{mode} = $1;
	 $dst{prot} = "ftp";
	 doLog( $LOGLEVEL{debug5}, "FTP set mode to $dst{mode}" );
	 unless ( $dst{mode} eq 'asc'? $ftp->ascii() : $ftp->binary() ) {
	    doLog( $LOGLEVEL{error}, "Error getting FTP xfer type!" );
	    next DEST;
	 }
	    
	 # FTP 'cd' to source directory...
	 if ( $dst{path} ne "" ) {
	     doLog( $LOGLEVEL{debug5}, "FTP cd to $dst{path}" );
	    unless ( $ftp->cwd( $dst{path} ) ) {
	       doLog( $LOGLEVEL{error}, 
		      "FTP 'cd' failed!" );
	       next DEST;
	    }
	 } # if

         doLog( $LOGLEVEL{debug3}, "FTP connected..." );

      #
      # Else if SSH, make sure key file exists
      # 
     } elsif ( $dst{prot} eq 'ssh' ) {
	 # Make sure key file exists
	 $keyFile = $keysDir . "/" . $dst{auth};
	 unless( -e $keyFile ) {
	     doLog( $LOGLEVEL{error}, "SCP key file ($keyFile) not found!" );
	     next DEST;
	 }
     } #elsif

      # For each file to be copied...
      foreach my $file ( @files ) {
	 
	 # FTP copy...
	 if ( $dst{prot} =~ 'ftp' ) {
	     doLog( $LOGLEVEL{debug5}, "Copy $file via FTP..." );

	    $res = $ftp->put( $file, $file ); 
	    ###print "ftp-put res=|$res|\n";#XXX
	    if ($res !~ /$file/ ) { 
		doLog( $LOGLEVEL{error}, 
		       "Error ($res) FTP putting file ($file) to"
		       . $dst{user} . "@" . $dst{host} );
		next DEST;
	    }

	 # SSH copy...
	 } elsif( $dst{prot} eq 'ssh' ) {

	     doLog( $LOGLEVEL{debug5}, "Copying $file via SSH..." );
	     
	    # Build SCP cmd and run it	    
	    my $cmd = $SCP . $scpOpt . " -i " . $keyFile . " " . $file 
		     . " '" . $dst{user} . "@" . $dst{host} . ":"; 
	     $cmd .= (exists $dst{path}) ? $dst{path} : "";
	     $cmd .= "'";
	    doLog( $LOGLEVEL{debug}, $cmd );
	    print `$cmd`;
	    if ( $? != 0 ) {
		doLog( $LOGLEVEL{error}, "Error (" . ($?>>8)
		       . ") SCPing file ($file) to " . $dst{user} . "@" 
		       . $dst{host} );
		next DEST;
	    } # if

	 # Local copy...
	 } else {
	    doLog( $LOGLEVEL{debug5}, "Copying $file locally..." );

	    my $cmd = "cp -p " . $file . " ";
	    $cmd .=  (exists $dst{path}) ? $dst{path} : "";
	    doLog( $LOGLEVEL{debug}, $cmd );
	    print `$cmd`;
            if ( $? != 0 ) {
               doLog( $LOGLEVEL{error}, "Error (" . ($?>>8) 
		      . ") copying file ($file) locally to" . $dst{path} ); 
	       next DEST;
	    } 
	 } # else

     } # foreach file

     # Close the FTP connection
     if ( $dst{prot} eq 'ftp' ) {
	 $ftp->quit();
     }      
    
  } # foreach dest
 

  doLog( $LOGLEVEL{debug4}, "Out doPushFiles..." );

} # sub doPushFiles

