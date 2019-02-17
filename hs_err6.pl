#!/usr/bin/perl

# Copyright 2006 Sun Microsystems, Inc.  All Rights Reserved.
# This software is provided "as is" and is entirely unsupported.
#
#------------------------------------------------------------------------------
# This script is written to help analyze HotSpot error dump (hs_err_pid*.log)
#
# Features:
#  + look up function names; symbols like "C [libjvm.so+0x0x2368ff]" are 
#    translated into real function names (e.g. jni_CallStaticVoidMethod+0x107).
#  + decode error id
#  + decode signal number and signal code
#  + disassemble instructions near crashing pc
#  + compare VM versions, and give a warning if the specified libjvm.so is not
#    the one that generated the error log
#  + Windows support
#  + WWW support, now runs as CGI script if file path includes "cgi"
#
# To-do:
#  + check for common errors
#  + decode stack values
#  + Sparc, i0-i7 register values
#
#------------------------------------------------------------------------------
# Command Line Syntax:
#  hs_err [ --jvm=<jvm path> ] [ --map=<Windows map file> ]
#         [ --subst=from_path,to_path ] 
#         <HotSpot error log>
#
# If an alternate JVM is specified by "--jvm", it will be used to find
# JVM symbols (i.e. those start with "V"). If the specified JVM is tgz'ed,
# it will be extracted to TMPDIR first.
#
# For Windows error log, a map file for its corresponding jvm[_g].dll can be
# specified with --map if the specified jvm[_g].dll's directory doesn't have 
# the map file. For other dll's, the script will only look for the 
# corresponding .map files under the same directories as the dll's.
# 
# The script is cross platform, e.g. it can translate a Windows log on 
# Solaris.
#------------------------------------------------------------------------------

  use IPC::Open2;
  use FindBin;
  use lib "$FindBin::Bin/../lib";
  use CGI;

#############################################################################
#                                                                           #
#                       C O N F I G U R A T I O N S                         #
#                                                                           #
#############################################################################

# temporary directory
  $TMPDIR = "/tmp";

# GNU tools
  $TAR = ($^O eq "linux" ? "tar" : "gnutar");      # need GNU tar
  $NM = ($^O eq "linux" ? "nm" : "nm -p -x");      # Solaris nm needs -p -x
  $STRINGS = "strings";
  $GREP = "grep";
  $ELFPH = ($^O eq "linux" ? "readelf -l" : "elfdump -p"); # elf program header

# HotSpot tools:
#    disasm  - cross platform disassembler
#    errorid - decode HotSpot error id
  $DISASM = "disasm";

#############################################################################
#                                                                           #
#                     H E L P E R     F U N C T I O N S                     #
#                                                                           #
#############################################################################

#############################################################################
### Printing

# space(n) returns a strings with n space characters. e.g. space(2) => "  "
sub space {
  my ($n) = @_;

  my $i, $str;
  $str = '';
  for ($i = 0; $i < $n; $i++) {
    $str .= (defined $HTML) ? "&nbsp;" : " ";
  }

  return $str;
}

sub br {
  return (defined $HTML) ? "<br>\n" : "\n";
}

sub bold {
  my ($s) = @_;
  return (defined $HTML) ? "<b>".$s."</b>" : $s;
}

sub italic {
  my ($s) = @_;
  return (defined $HTML) ? "<i>".$s."</i>" : $s;
}

sub _print_ {
  if (defined $HTML) {
     my $s;
     foreach $s(@_) {
       my $t = $s;
       # convert white space into "&nbsp;"
       while ($t =~ /(\s\s+)/) {
         print $`;
         print space(length($1));
         $t = $';
       }
       print $t;
     }
  } else {
    print @_;
  }
}

sub _debug_ {
  _print_ (@_) if ($DEBUG eq "true");
}

sub _info_ {
  my $_info_first_line = 'true';
  my $s;
  foreach $s(@_) {
    if (defined $_info_first_line) {
      _print_ ((defined $HTML) ? "<font color=navy>" : ";; ");
      undef $_info_first_line;
    } else {
      _print_ ((defined $HTML) ? br : br.";; ");
    }

    _print_ $s;
  }

  print ((defined $HTML) ? "</font>" : "");
}

sub _warn_ {
  my $_warn_first_line = 'true';
  my $s;
  foreach $s(@_) {
    if (defined $_warn_first_line) {
      _print_ ((defined $HTML) ? "<font color=maroon><b>Warning: </b><i>" : "Warning: ");
      undef $_warn_first_line;
    } else {
      _print_ space(9);
    }

    _print_ $s, br;
  }
  
  _print_ ((defined $HTML) ? "</i></font>" : "");
}

#############################################################################
### Error ID

  sub decode_errorid {
    my ($id) = @_;
    my $line, $file;

    # last 4 digits are line number
    if ($id =~ /([0-9A-F]{4})$/) {
      $line = hex($1);
      $id = $`;
    }

    $file = "";
    while ($id =~ /([0-9A-F]{2})/g) {
      $file .= sprintf("%c", hex($1) + 32);
    };

    return "$file, $line";
  }

#############################################################################
### Signals

  # Signal names and codes
  %linux_signames=(
     4 => SIGILL,
     7 => SIGBUS,
     8 => SIGFPE,
    11 => SIGSEGV,
  );

  %linux_sicodes=(
     # si_code for user generated signals
     user_generated => {
        0 => "SI_USER /* Sent by kill, sigsend, raise.  */",
     },

     # si_code for SIGILL
     SIGILL => {
        1 => "ILL_ILLOPC /* Illegal opcode.  */",
        2 => "ILL_ILLOPN /* Illegal operand.  */",
        3 => "ILL_ILLADR /* Illegal addressing mode.  */",
        4 => "ILL_ILLTRP /* Illegal trap. */",
        5 => "ILL_PRVOPC /* Privileged opcode.  */",
        6 => "ILL_PRVREG /* Privileged register.  */",
        7 => "ILL_COPROC /* Coprocessor error.  */",
        8 => "ILL_BADSTK /* Internal stack error.  */",
     },

     # si_code for SIGFPE
     SIGFPE => {
        1 => "FPE_INTDIV /* Integer divide by zero.  */",
        2 => "FPE_INTOVF /* Integer overflow.  */",
        3 => "FPE_FLTDIV /* Floating point divide by zero.  */",
        4 => "FPE_FLTOVF /* Floating point overflow.  */",
        5 => "FPE_FLTUND /* Floating point underflow.  */",
        6 => "FPE_FLTRES /* Floating point inexact result.  */",
        7 => "FPE_FLTINV /* Floating point invalid operation.  */",
        8 => "FPE_FLTSUB /* Subscript out of range.  */",
     },

     # si_code for SIGBUS
     SIGBUS => {
        1 => "BUS_ADRALN /* Invalid address alignment.  */",
        2 => "BUS_ADRERR /* Non-existant physical address.  */",
        3 => "BUS_OBJERR /* Object specific hardware error.  */"
     },

     # si_code for SIGSEGV
     SIGSEGV => { 
        1 => "SEGV_MAPERR /* Address not mapped to object.  */",
        2 => "SEGV_ACCERR /* Invalid permissions for mapped object.  */"
     },
  );

  %solaris_signames=(
     4 => SIGILL,
     8 => SIGFPE,
    10 => SIGBUS,
    11 => SIGSEGV,
  );

  # like signal numbers, signal codes are platform specific. but for the
  # signal codes we care about, they are the same on Solaris and Linux.
  %solaris_sicodes=%linux_sicodes;

  %windows_signames=(
    "0x80000001" => "EXCEPTION_GUARD_PAGE_VIOLATION",
    "0x80000002" => "EXCEPTION_DATATYPE_MISALIGNMENT /* The thread tried to read or write data that is misaligned on hardware that does not provide alignment. For example, 16-bit values must be aligned on 2-byte boundaries; 32-bit values on 4-byte boundaries, and so on. */",
    "0x80000003" => "EXCEPTION_BREAKPOINT /* A breakpoint was encountered. */",
    "0x80000004" => "EXCEPTION_SINGLE_STEP",
    "0xc0000005" => "EXCEPTION_ACCESS_VIOLATION /* The thread tried to read from or write to a virtual address for which it does not have the appropriate access. */",
    "0xc0000006" => "EXCEPTION_IN_PAGE_ERROR /* The thread tried to access a page that was not present, and the system was unable to load the page. For example, this exception might occur if a network connection is lost while running a program over the network. */",
    "0xc0000008" => "EXCEPTION_INVALID_HANDLE",
    "0xc0000017" => "EXCEPTION_NO_MEMORY",
    "0xc000001d" => "EXCEPTION_ILLEGAL_INSTRUCTION /* The thread tried to execute an invalid instruction. */",
    "0xc0000025" => "EXCEPTION_NONCONTINUABLE_EXCEPTION /* The thread tried to continue execution after a noncontinuable exception occurred. */",
    "0xc0000026" => "EXCEPTION_INVALID_DISPOSITION /* An exception handler returned an invalid disposition to the exception dispatcher. Programmers using a high-level language such as C should never encounter this exception. */",
    "0xc000008c" => "EXCEPTION_ARRAY_BOUNDS_EXCEEDED /* The thread tried to access an array element that is out of bounds and the underlying hardware supports bounds checking. */",
    "0xc000008d" => "EXCEPTION_FLOAT_DENORMAL_OPERAND /* One of the operands in a floating-point operation is denormal. A denormal value is one that is too small to represent as a standard floating-point value. */",
    "0xc000008e" => "EXCEPTION_FLOAT_DIVIDE_BY_ZERO /* The thread tried to divide a floating-point value by a floating-point divisor of zero. */",
    "0xc000008f" => "EXCEPTION_FLOAT_INEXACT_RESULT /* The result of a floating-point operation cannot be represented exactly as a decimal fraction. */",
    "0xc0000090" => "EXCEPTION_FLOAT_INVALID_OPERATION /* This exception represents any floating-point exception not included in this list. */",
    "0xc0000091" => "EXCEPTION_FLOAT_OVERFLOW /* The exponent of a floating-point operation is greater than the magnitude allowed by the corresponding type. */",
    "0xc0000092" => "EXCEPTION_FLOAT_STACK_CHECK /* The stack overflowed or underflowed as the result of a floating-point operation. */",
    "0xc0000093" => "EXCEPTION_FLOAT_UNDERFLOW /* The exponent of a floating-point operation is less than the magnitude allowed by the corresponding type. */",
    "0xc0000094" => "EXCEPTION_INTEGER_DIVIDE_BY_ZERO /* The thread tried to divide an integer value by an integer divisor of zero. */",
    "0xc0000095" => "EXCEPTION_INTEGER_OVERFLOW /* The result of an integer operation caused a carry out of the most significant bit of the result. */",
    "0xc0000096" => "EXCEPTION_PRIVILEGED_INSTRUCTION /* The thread tried to execute an instruction whose operation is not allowed in the current machine mode. */",
    "0xc00000fd" => "EXCEPTION_STACK_OVERFLOW /* The thread used up its stack.  */",
    "0xc000013a" => "EXCEPTION_CONTROL_C_EXIT",
  );

  sub decode_siginfo {
    ($_) = @_;                                       # parameters
    my ($rslt, $signum, $sigcode, $name, $code);     # local variables

    @rslt = ();

    if ($target_os eq "windows") {
      $signum=$1 if (/ExceptionCode=(0x[0-9a-f]+)/);
    } else {
      $signum=$1 if (/si_signo=(\d+)/);
    }

    $sigcode=$1 if (/si_code=(\d+)/);

    $name = $signames{$signum};
    if ($name) {
      push(@rslt, "si_signo=$signum\t$name");
    }

    $code = $sicodes{$name}{$sigcode} ||
            $sicodes{user_generated}{$sigcode};
    if ($code) {
      push(@rslt, "si_code=$sigcode\t$code");
    }

    return @rslt;
  }

#############################################################################
### Instructions near crashing PC

  sub decode_instructions {
    my ($pc, @inst_lines) = @_;

    # The disasm tool (or a symbolic link) should be installed in the same
    # directory as hs_err
    my $installdir = $FindBin::RealBin;
    my $disasm = join("/", $installdir, $DISASM);
    my $cmdline = $disasm . " --cpu=$target_cpu --ip=$pc";
    $cmdline .= " --debug" if ($DEBUG eq true);

    if (-x $disasm) {
      _debug_ "Executing $cmdline\n";

      my $pid = open2(\*RDR, \*WTR, $cmdline);

      # send hexdump to disasm
      print WTR join("\n", @inst_lines), "\n";
      close(WTR);

      # read disasm output
      @rslt = <RDR>;
      close(RDR);
      waitpid $pid, 0;

      chomp(@rslt);
      return @rslt;

    } else {
      _debug_ "Can't execute $disasm\n";
      return ();
    }
  }

#############################################################################
### Load symbol table & function lookup

  sub get_loadbase {
    my ($fullpath) = @_;

    open(RD_ELFPH, "$ELFPH \"$fullpath\" |");
    my @lines = <RD_ELFPH>;
    close(RD_ELFPH);
    chomp(@lines);

    my ($line, $base);
    foreach $line(@lines) {
      # base address of a library is the smallest address of its
      # loadable segments (PT_LOAD)
      if ($line =~ /LOAD/) {
        my @cols = split(/\s+/, $line);
        my $val = ($^O eq "linux" ? $cols[3] : $cols[2]);
        if (!defined($base) || hex($base) > hex($val)) {
          $base = $val;
        }
      }
    }

    return $base;
  }

  sub read_symbol_table {
    my ($libname) = @_;

    my $fullpath = $libpath{$libname};

    if (! -f $fullpath) {
      # try to substitute in name to find library
      $fullpath =~ s/$from_path/$to_path/;
    }

    my @syms = ();

    if ($target_os eq "windows") {
      if ($libname =~ /jvm(_g|).dll/) {
        if (!defined $jvmmapfile) {
          $jvmmapfile = $fullpath;
          $jvmmapfile =~ s/(dll|DLL)\Z/map/;
          if (! -e $jvmmapfile) {
#           _warn_ "Warning: no map file found for $jvmpath!\n";
            $jvmmapfile = $jvmmappath;
          }
        }
        $mapfile = $jvmmapfile;
      } else {
        $mapfile = $fullpath;
        $mapfile =~ s/(dll|DLL)\Z/map/;
      }

      if ($mapfile =~ /map\Z/ && open(MAP, "<$mapfile")) {
        $begin = 0;
        $numOfSym = 0;
        while (<MAP>) {
          if (/^ Preferred load address is (.+)$/) {
            $loadbase_table{$libname} = $1;
          }
          if (/ Address\s+Publics/) { $begin = 1; }
          if ($begin) {
            if (/ f /) {
              # a function name
              @line = split(/\s+/);
              if ($#line >= 5) {
                # try to follow Solaris/Linux nm output format
                $syms[$numOfSym++] = join(' ', $line[3], $line[4], $line[2]);
              }
            }
          }
        }
        close MAP;
      }
    } else {                                       # Solaris/Linux
      if ((! -f $fullpath) && ($fullpath =~ /\A\/\.automount\/(.+)\/root\/(.*)\Z/)) {
        # hack to deal with Linux auto mounter timeout; rename amd internal
        # names to standard /net/... format
        $fullpath = "/net/$1/$2";
      }

      $loadbase_table{$libname} = get_loadbase($fullpath);

      open(RD_NM, "$NM \"$fullpath\" |");          # read symbol table
      @syms = <RD_NM>;
      close(RD_NM);
      chomp(@syms);                                # remove '\n'
      if ($#syms < 1) {
        _warn_ "$fullpath does not exist or it has been stripped";
      }
    }

    # nm output has the following format:
    #    +------------------------ base address
    #    |     +------------------ symbol type
    #    |     |       +---------- symbol name
    #    v     v       v
    # 0015c2b0 t jni_FindClass

    my @sorted_syms = sort {$a cmp $b} @syms;      # sort nm output

    $symbol_table{$libname} = [@sorted_syms];      # assign array to hash
  }

  # usage: ($funcname, $offset) = addr2func("libjvm.so", "0x12345");
  #                               or handle-failure
  sub addr2func {
    my ($libname, $offset) = @_;

    return () if (!defined $libpath{$libname});    # libname is invalid

    if (!defined $symbol_table{$libname}) {
      read_symbol_table($libname);
    }

    my @syms = @{$symbol_table{$libname}};         # retrieve array from hash 

    my ($low, $high, $mid, $symaddr, $loadbase, $type, $funcname);

    $loadbase = $loadbase_table{$libname};

    # binary search to find function name
    $low = 0; $high = $#syms; $mid = ($high + $low) >> 1;
    while ($low + 1 < $high) {
      ($symaddr) = split(/[\s\t]+/, $syms[$mid], 1);
      if (hex($symaddr) - hex($loadbase) > hex($offset)) {
         $high = $mid; $mid = ($high + $low) >> 1;
      } else {
         $low = $mid; $mid = ($high + $low) >> 1;
      }
    }

    ($symaddr, $type, $funcname) = split(/[\s\t]+/, $syms[$low]);

    if (hex $symaddr != 0) {
      my $offstr = sprintf("0x%lx", hex($offset) - (hex($symaddr) - hex($loadbase)));
      return ($funcname, $offstr);
    } else {
      return ();
    }
  }

#############################################################################
### Given vm_info string, find the corresponding libjvm[_g].so

  sub find_jvm {
    my ($vm_info) = @_;

    my ($vmpath);

    # java/re archive
    if ($vm_info =~ /java_re/ ||
        $vm_info =~ /\([\d\.]+-(beta|beta2|fcs)-b[0-9a-f]+\)/) {
      my ($version, $milestone, $build, $os, $cpu);

      # e.g. ... Client VM (1.5.0-beta2-b49) for linux-x86, built on ...
      # fcs release does not have milestone (e.g. 1.5.0-b64)
      # fastdebug version string (since 1.6): 1.6.0-ea-fastdebug-b46
      if ($vm_info =~ /VM \((.*)\) for (\w+)-(\w+), built on/) {
        @vers = split(/-/, $1);
        $version = $vers[0];
        $build = $vers[$#vers];
        $milestone = $vers[1] if ($#vers > 1);
        $fastdebug = $vers[2] if ($#vers > 2);
        $os = $2;
        $cpu = $3;

        $milestone = "fcs" if ($milestone eq "");

        if ($cpu eq "sparc" && $vm_info =~ "64-Bit") {
          $cpu = "sparcv9";
        }

        if ($cpu eq "x86") {
          $cpu1 = "i586";
          $cpu2 = "i386";
        } else {
          $cpu1 = $cpu;
          $cpu2 = $cpu;
        }

        $RE_BASE = "/java/re/jdk/$version";
        if (-e "$RE_BASE/promoted/$milestone/$build/binaries") {
          $vmpath="$RE_BASE/promoted/$milestone/$build/binaries/$os-$cpu1";
        } elsif (-e "$RE_BASE/archive/$milestone/$build/binaries") {
          $vmpath="$RE_BASE/archive/$milestone/$build/binaries/$os-$cpu1";
        } elsif (-e "$RE_BASE/archive/$milestone/binaries") {
          $vmpath="$RE_BASE/archive/$milestone/binaries/$os-$cpu1";
        } else {
          # can't find corresponding RE directory
          $vmpath="";
        }

        $vmpath .= "/$fastdebug";

        if ($os eq "windows") {
          $vmpath .= "/jre/bin";
        } else {
          $vmpath .= "/jre/lib/$cpu2";
        }

        if ($vm_info =~ /Client VM/) {
          $vmpath .= "/client/";
        } elsif ($vm_info = ~/Server VM/) {
          $vmpath .= "/server/";
        } else {
          $vmpath .= "/";                    # FIXME: new build type from RE??
        }

        $vmpath .= defined $is_jvmg ? $jvmg_name : $jvm_name;
      }

    } elsif ($vm_info =~ /by prtadmin/) {        ## PRT archive
    }

    return $vmpath;
  }

#############################################################################
#                                                                           #
#                        M A I N      P R O G R A M                         #
#                                                                           #
#############################################################################

#############################################################################
### Command line or CGI?

  if ($0 =~ /cgi/) {
     $WWW = "true";             # 'CGI' is a Perl module, use 'WWW' instead
  } else {
     undef $WWW;
  }

#############################################################################
### CGI Interface

  if (defined $WWW) {
    $cgi = new CGI;

    if (defined $cgi->param('file')) {
      # invoked by the "submit" button: upload hs_err*.log file, parse options
      my $filename = $cgi->param('file');
      my $fh = $cgi->upload('file');

      @lines = <$fh>;
      foreach $line(@lines) {
        $line =~ s/\r\n/\n/;
      }
      chomp(@lines);

      if ($cgi->param('output_format') eq 'HTML') {
        $HTML = 'true';
      } else {
        undef $HTML;
      }

      if (defined $HTML) {
        print $cgi->header;
        print $cgi->start_html(
                    -title=>"hs_err: $filename",
                    -BGCOLOR=>'white',
        );
        print "<code>";
      } else {
        print $cgi->header(-type=>'text/plain');
      }

    } else {
      # generate a web page for submitting hs_err*.log file
      print $cgi->header;
      print $cgi->start_html(
                    -title=>'hs_err: HotSpot Error Log Decoder',
                    -BGCOLOR=>'white',
      );

      print $cgi->start_multipart_form;
      print "Decode hs_err*.log:", $cgi->filefield(-name=>'file', -size=>'40');
      print $cgi->br;
      print "Output format:", 
            $cgi->radio_group(-name=>'output_format',
                              -values=>['HTML', 'Text'],
                              -defaults=>'Text',
            );
      print $cgi->br;
      print $cgi->submit('Submit');
      print $cgi->endform;
      print $cgi->end_html;
      exit;
    }
  }

#############################################################################
### Command line parser

  if (!defined $WWW) {
    while ($ARGV[0] =~ /\A--/) {
      $_ = shift @ARGV;

      # user can use ' ' instead of '=' to separate argument name and value,
      # so it's a little easier to use automatic filename completion.
      if (/\A--jvm\Z/) {
        $_ .= "=" . shift @ARGV;
      } elsif (/\A--subst\Z/) {
        $_ .= "=" . shift @ARGV;
      } elsif (/\A--map\Z/) {
        $_ .= "=" . shift @ARGV;
      }

      if (/\A--help/) {
        print "Usage: hs_err [ --jvm=<jvm path> ] [ --map=<Windows map file> ]".
                           " [ --subst=from_path,to_path ]".
                           " <HotSpot error log> \n";
        exit 1;

      } elsif (/\A--jvm=/) {
        $jvmpath = $';
        if (! -e $jvmpath) {
#          print STDERR "(*****) Can't find $jvmpath\n";
#          undef $jvmpath;
        } else {
          # unzip libjvm if a tgz file is specified
          if ($jvmpath =~ /\.tgz\Z/) {
            $unzipdir = join("/", $TMPDIR, join("", "hserr", $$));
            mkdir "$unzipdir", 0744;
            open(jvmzip, "$TAR xvfz $jvmpath -C $unzipdir |");
            @lines = <jvmzip>;
            close(jvmzip);
            $jvmpath = join ("/", $unzipdir, $lines[0]);
          }
        }

      } elsif (/\A--subst=/) {
        ($from_path, $to_path) = split(/,/, $');
        if (! -d $to_path) {
          print STDERR "(*****) Can't find $to_path\n";
          undef $from_path;
          undef $to_path;
        }      

      } elsif (/\A--map=/) {
        $jvmmappath = $';
        if (! -e $jvmmappath) {
          die "--map doesn't specify a good path: $jvmmappath";
        }

      } elsif (/\A--debug/) {
        $DEBUG = true;

      }
    }

    # read HotSpot error log file
    @lines = <>;
    foreach $line(@lines) {
      $line =~ s/\r\n/\n/;
    }
    chomp(@lines);
  }

#############################################################################
### 1st pass: read library paths and vm_info string

  undef $section;
  @buffer = ();
  foreach $line(@lines) {
    if ($line =~ /^\s*$/) {
      # empty line marks end of a multi-line section

      if ($section eq "dll") {
        foreach $str(@buffer) {
          while ($str =~ /\b(0x)*[0-9a-f]+[\s\t]/g) {
            $fullpath = $';
          }
          $fullpath =~ s/^[\s\t]+//;
          $fullpath =~ s/[\s\t]+$//;

          # replace Windows path separator '\' with Unix style '/'
          $fullpath =~ s/\\/\//g;
          if ($fullpath =~ /\//) {          # pathname contains '/'
            @dirs = split(/\//, $fullpath);
            $libname = $dirs[$#dirs];
            if (!defined $libpath{$libname}) {
              $libpath{$libname} = $fullpath;
            }
          }
        }
      }

      undef $section;
      @buffer = ();

    } elsif ($line =~ /^vm_info: /) {
      $vminfo{errlog} = $';
      if ($vminfo{errlog} =~ /for (\w+)\-(\w+), built on/) {
         $target_os = $1;
         $target_cpu = $2;
      }

    } elsif ($line =~ /\ADynamic libraries/) {
      $section = "dll";
      @buffer = ();

    } elsif (defined $section) {
      push(@buffer, $line);
    }
  }

  # set up OS/CPU specific values
  if (!defined $vminfo{errlog}) {
    # old hs_err dump
    $target_os = $^O;
    $target_cpu = `uname -m`;
    chomp($target_cpu);
  }

  if ($target_os eq "solaris") {
    %signames = %solaris_signames;
    %sicodes = %solaris_sicodes;
    $jvm_name = "libjvm.so";
    $jvmg_name = "libjvm_g.so";
  } elsif ($target_os eq "linux") {
    %signames = %linux_signames;
    %sicodes = %linux_sicodes;
    $jvm_name = "libjvm.so";
    $jvmg_name = "libjvm_g.so";
  } else {
    %signames = %windows_signames;
    %sicodes = ();
    $jvm_name = "jvm.dll";
    $jvmg_name = "jvm_g.dll";
  }

  # FIXME: figure out product or debug VM through VM version string
  if (defined $libpath{$jvmg_name}) {
     $is_jvmg = "true";
  } else {
     undef $is_jvmg;
  }

  # --jvm switch is used to override libjvm[_g].so path; if --jvm is not in
  # use, find JVM location through the hs_err*.log file.
  if (! defined $jvmpath) {
     $jvmpath = defined $is_jvmg ? $libpath{$jvmg_name} : $libpath{$jvm_name};
  }

  # if $jvmpath does not exist, find the corresponding JVM from Java/RE or PRT
  # archive.
  if (! -e $jvmpath) {
     $path = find_jvm($vminfo{errlog});
     if (-e $path) {
       _warn_ "Can't find \"$jvmpath\"", "using \"$path\"";
       $jvmpath = $path;
     }
  }

  # reassign $jvmpath to $libpath, which is used later to read symbols
  if (! defined $is_jvmg) {
     $libpath{$jvm_name} = $jvmpath;
  } else {
     $libpath{$jvmg_name} = $jvmpath;
  }

  open(RD_JVM, "$STRINGS \"$jvmpath\" | $GREP \", built on\" |");
  $vminfo{$jvmpath} = <RD_JVM>;
  close(RD_JVM);
  chomp($vminfo{$jvmpath});

  # trim vm_info string
  $vminfo{$jvmpath} =~ s/^\s+//;
  $vminfo{$jvmpath} =~ s/\s+$//;
  $vminfo{errlog}   =~ s/^\s+//;
  $vminfo{errlog}   =~ s/\s+$//;

#############################################################################
### 2nd pass: print error log to stdout with annotations

  undef $section;
  @buffer = ();
  foreach $line(@lines) {
    if ($line =~ /^\s*$/) {
      # empty line marks end of a multi-line section

      if ($section eq "instructions") {
         @rslt = decode_instructions($pc, @buffer);
         _info_ @rslt, "";
      }

      undef $section;
      @buffer = ();
    }

    _print_ $line;

    if ($line =~ /^Native frames:/) {
      # check if JVM is the same one that generated the error dump
      if (-e $jvmpath && $vminfo{errlog} ne $vminfo{$jvmpath}) {
        _warn_ "This error log is *not* generated by the following JVM:",
               "  $jvmpath",
               "",
               "Expected vm_info: [$vminfo{errlog}]",
               "Actual vm_info:   [$vminfo{$jvmpath}]",
               "",
               "JVM symbol lookup may be incorrect.",
               "Please use --jvm=<path/to/jvm> to point to the correct JVM.",
               "";
#        $disable_vm_symbol_lookup = "true";
      }

    } elsif ($line =~ /^[CV]  ?\[(.+)\+([0-9a-fA-FxX]+)\]/) { 
      # This regular expression looks for strings in the form of "V  [$1+$2]",
      # or "C  [$1+$2]", where $1 can be anything and $2 is a hexdecimal
      # number. e.g."V  [libjvm.so+0x2368ff]"
      my $library_name = $1;
      my $library_offset = $2;

      if ($line =~ /^C/ || !defined $disable_vm_symbol_lookup) {
        ($funcname, $offset) = addr2func($library_name, $library_offset);
        _info_ " $funcname+$offset" if ($funcname);
      }

    } elsif ($line =~ /^siginfo/) {
      @rslt = decode_siginfo($line);
      _info_ "", @rslt;

    } elsif ($line =~ /^Instructions/) {
      $pc = $1 if ($line =~ /pc=(\w+)/);
      $section = "instructions";
      @buffer = ();

    } elsif ($line =~ /^#  Internal Error \(([0-9A-F]+)( (01|FF))?\)/) {
      _info_ "", "Error ID is " . decode_errorid($1);

    } elsif (defined $section) {
      push(@buffer, $line);
    }

    _print_ br;
  }

#############################################################################
### 3rd pass: try to identify known issues
  $_ = join("\n", @lines);          # put everything in a single string, easier
                                    # to use regular expressions.

  # TODO: move this into hs_err.db file
  $pattern = "/NPTL 0.29/ && /__libc_free\+/ && /safepoint \(shutting down\)/";
  $message = "Vanilla Redhat 9 (NPTL 0.29) needs patch, see bug 4885046";
  
  if (eval($pattern)) {
    _print_ ";;\n;; $pattern\n;; ==> $message\n;;\n";
  }

#############################################################################
### Clean up, remove temp files

  if (defined $unzipdir) {
    system("rm", "-rf", $unzipdir);
  }

  if (defined $HTML) {
    print "</code>";
    print $cgi->end_html;
  }

