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
#   use lib (dirname($0) . "/perllib");

# Add-on modules
#    use Net::FTP;

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
$LS{mswin} = "dir";

# Delete file command
my %RM;
$RM{unix} = "rm -f";
$RM{mswin} = "del";

# Check sum command (not currently used since all O/Ss not covered!)
#my %SUM;
#$SUM{unix} = "/usr/bin/cksum";
#$SUM{mswin} = "cksum";

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
#my $thisDir = dirname $0;
#my $thisFile = basename $0;
#$thisFile =~ '(.+)\.\w+?';  
#$thisFile = $thisDir . "/" . $1 . ".conf";
#(-e $thisFile)
#    or doErrorExit( "Cannot find config file ($thisFile)!" );  
#require $thisFile;



GOUNPACK: 
if ( defined $cfg{src_unpack} ) {
    doUnpack()
	or doErrorExit( "Error unpacking files!" );
}




#--------------------

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



