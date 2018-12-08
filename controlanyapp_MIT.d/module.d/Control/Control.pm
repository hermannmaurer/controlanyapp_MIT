package Control::Control;

#########################################
# Control.pm
#########################################
#
# Author:  Hermann Maurer
# Email:   hmfetch@gmail.com
#
# COPYRIGHT (c) 2018 Hermann Maurer
#
#########################################
our $VERSION = "01";
#########################################

use strict; use warnings;
use Data::Dumper;
use Carp qw(confess);
#use Term::ReadKey;
use Time::HiRes qw(time);
use Term::ANSIColor;
use FileHandle; # or use IO::Handle, autoflush
use POSIX qw(strftime);
use File::Basename;
use File::Path;

our $DEBUG=0;
$|=1; # autoflush for stdout


sub new {

	my $class = shift;
	my $self = {

		id => shift,
		taskArray => shift,
		logPath => shift,

		offset => 0.1,

		# derived from taskArray
		taskHash => undef,
	};
	my $func=(caller(0))[3];

	bless $self, $class;

	# Validity check
	# Default: param1
	if( ! defined $self->{id}) {
		$self->{id} = basename( $0);
	} elsif( ref(\$self->{id}) ne 'SCALAR') {
		confess( "$func: param1 [$self->{id}] is not a SCALAR");
	}
	# Mandatory: param2
	if( ref($self->{taskArray}) ne 'ARRAY') {

		$self->{taskArray} = "<undef>" unless defined $self->{taskArray};
		confess( "$func: param2 [$self->{taskArray}] is not an ARRAY ref");
	}
	if( ! @{$self->{taskArray}}) {
	        confess ("$func: param2 taskArray is empty");
	}
	if( @{$self->{taskArray}}%2) {
	
		confess ("$func: param2 taskArray needs an even number of elements");
	}
	# Copy array to hash, array is used to keep sequence
	%{$self->{taskHash}} = @{$self->{taskArray}};
	
	my $keyCount = keys %{$self->{taskHash}};
	if( $keyCount != @{$self->{taskArray}}/2) {
	
		confess("$func: param1 taskArray has obviousely some identical keys defined");
	}
	# Default: param3
	if( ! defined $self->{logPath}) {

		confess( "$func: env variable 'HOME' is not set") unless defined $ENV{HOME};
		#$self->{logPath}="/var/log/controlanyapp.d/$self->{id}.log";
		$self->{logPath}="$ENV{HOME}/.controlanyapp.d/$self->{id}.log";
		my $dirname = dirname( $self->{logPath});
		mymkpath( $dirname); # will confess in case of failure
	} elsif( ref(\$self->{logPath}) ne 'SCALAR') {
		confess( "$func: param3 [$self->{logPath}] is not a SCALAR");
	}
	my $response = qx(touch "$self->{logPath}" 2>&1);
	if( $?) {
		confess("$func: param3 logPath [$self->{logPath}], touch test failed [$response]");
	}

	return $self;
}

sub menu {

	my $self=shift;
	my $resultString = shift;
	my $verbose = shift || 0;
	my $func = (caller(0))[3];

	_clear();

	# geth length of longest key literal
	my @sort = sort {length $b <=> length $a} keys %{$self->{taskHash}};
	my $length=length( $sort[0]) + 2;

	print "\n";
	print "+++ CONTROL$VERSION $self->{id} BEGIN +++\n";

	my %keyMap;
	my $digit=1;
	my $letterS='a';
	my $letterB='A';
	for( my $i=0, my $j=0; $i<@{$self->{taskArray}}/2; $i++, $j+=2) {

		my $key = $self->{taskArray}[$j];
		my $task = $self->{taskArray}[$j+1];

		if( $i<10) {

			$verbose ? printf( " %d %-${length}s task [$task->[1]]\n", $digit, "[$key]")
				 : print " $digit [$key]\n";
			$keyMap{$digit}=$key;
			$digit++;
			$digit=$digit%10;

		} elsif( $i<35) {

			$verbose ? printf( " $letterS %-${length}s task [$task->[1]]\n", "[$key]")
				 : print " $letterS [$key]\n";
			$keyMap{$letterS}=$key;
			$letterS++;
			$letterS++ if( $letterS eq 'q'); # no typo, increase additional to the one before

		} else {

			$verbose ? printf( " $letterB %-${length}s task [$task->[1]]\n", "[$key]")
				 : print " $letterB [$key]\n";
			$keyMap{$letterB}=$key;
			$letterB++;
		}
	}

	# Others
	print "\n";
	if( defined $self->{logPath}) {
		( $verbose) ? print " : [less log] logPath [$self->{logPath}]\n" : print " : [less log]\n";
	} else {

	}
	print " . [toggle verbose]\n";
	print " q [quit] # [license]\n";

	if( $resultString) {
		print "\n$resultString\n\n";
	}
	print "+++ CONTROL$VERSION $self->{id} END +++\n";

	return \%keyMap;
} 

sub execTask {

	my $self=shift;
	my $key = shift;
	my $taskHash = shift;
	my $func=(caller(0))[3];

	confess( "$func: key [$key] is not present in taskHash") unless exists $taskHash->{$key};

	my( $safety, $task, $fixedResult) = @{$taskHash->{$key}};

	if( $safety) {
		print colored("SAFETY FLAG SET: Are you sure, press y[es] or n[o] or q[quit]\n", 'magenta');
		my $key = $self->_readKey( {y=>"", n=>"", q=>""});
		return 'ABORT' if( $key eq 'n');
	}

	print qq(	system("$task")\n);
	system("$task");

	my $result;
	if( defined $fixedResult) {
		$result = $fixedResult;
	} else {
		$result = $? ? colored('NOK', 'red') : colored('OK', 'green');
	}

	return $result;
}

sub start {

	my $self = shift;
	my $func=(caller(0))[3];

	my $resultString="";
	#my $keyMap=menu( $resultString);
	my $verbose=0;

	for(;;) { #SEQUENCE

		my $keyMap=$self->menu( $resultString, $verbose);
		my $key=$self->_readKey( $keyMap);
		if( $key eq ".") {

			$verbose = $verbose ? 0 : 1; # toggle
			#print "verbose [$verbose]\n";
			next;
		} 
		if( $key eq ":") {

			if( $self->{logPath}){
				system( "less -r $self->{logPath}");
			}
			next;
		} 
		if( $key eq "#") {

			showLicense();

		} else {

			my $result=$self->execTask( $keyMap->{$key}, $self->{taskHash});

			$resultString="Last Key [$key] Task [$keyMap->{$key}] Result [$result]\nNOTE: Result depends on the shell command exit code.";
			print "\n$resultString\n";

			# Make log entry 
			if( $self->{logPath}) {

				my $timestamp = strftime "%Y%m%d %H:%M:%S %a", localtime();
				system( qq(echo "$timestamp: Key [$key] [$keyMap->{$key}] Result [$result]" >> $self->{logPath})) if( $self->{logPath});
			}
		}

		print colored("	<< Press Space to move on >>\n", 'magenta');
		$self->_readKey( {' '=>""});
	}
}

sub showLicense {

       print <<END;

MIT License

Copyright (c) 2018 Hermann Maurer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

END
}

#sub _readKey {
#
#	my $self=shift;	
#	my $keyMap=shift;
#	my $func=(caller(0))[3];
#
#	my $offset=$self->{offset};
#
#	# add quit
#	$keyMap->{q}=""; # quit
#	$keyMap->{'.'}=""; # verbose menue
#	$keyMap->{':'}=""; # less log
#	$keyMap->{'#'}=""; # show license
#
#	ReadMode "raw";
#
#	my $key;
#	for(;;) {
#		my $refTime=time();
#		$key = ReadKey(0);
#		if( exists $keyMap->{$key}) {
#
#			if( time() < $refTime + $offset) {
#				#print " last key [$key]\n";
#				next;
#			}
#			last;
#		}
#	}
#	ReadMode "restore";
#
#	if( $key eq "q") {
#
#		print "bye!\n";
#		exit;
#	} 
#	#print "key [$key]\n";
#
#	return $key;
#}

sub _readKey {

	my $self=shift;	
	my $keyMap=shift;
	my $func=(caller(0))[3];

	my $offset=$self->{offset};

	# add quit
	$keyMap->{q}=""; # quit
	$keyMap->{'.'}=""; # verbose menue
	$keyMap->{':'}=""; # less log
	$keyMap->{'#'}=""; # show license

	system "stty cbreak -echo </dev/tty >/dev/tty 2>&1";
	#system "stty", '-icanon', 'eol', "\001";

	my $key;
	for(;;) {
		my $refTime=time();

		$key = getc(STDIN);

		if( exists $keyMap->{$key}) {

			if( time() < $refTime + $offset) {
				#print " last key [$key]\n";
				next;
			}
			last;
		}
	}
	system "stty -cbreak echo </dev/tty >/dev/tty 2>&1";
	#system 'stty', 'icanon', 'eol', '^@'; # ASCII NUL

	if( $key eq "q") {

		print "bye!\n";
		exit;
	} 
	#print "key [$key]\n";

	return $key;
}

#my $placeholderRegex=qr(\0([^\0]+)\0);
my $placeholderRegex=qr(<!(.+?)!>); # !!! ADJUST HERE !!!
sub _placeholderReplacement {

        my $stringRef = \shift;
        my $map    = shift;
        my $func=(caller(0))[3];

        # Precondition check
        if( ref($stringRef) ne "SCALAR") {

                $stringRef="<undef>" unless defined $stringRef;
                confess "$func: param1 [$stringRef] not a ref to a scalar";
        }

        # Precondition check
        if (ref($map) ne "HASH") {

                $map="<undef>" unless defined $map;
                confess "$func: param2 [$map] not a HASH ref";
        }

        $DEBUG && print "DEBUG: $func string before [$$stringRef]\n";

        # NOTE: the regex switch s makes the . match \n
        if (my @placeholder = $$stringRef =~ /$placeholderRegex/g) {

                for (@placeholder) {

                        if (exists $map->{$_}) {

                                $$stringRef =~ s/<!$_!>/$map->{$_}/; # !!! ADJUST HERE !!!

                        } else {

                                confess "$func: Cannot replace placeholder <!$_!> of string  [$$stringRef]\n";
                        }
                }
        }

        $DEBUG && print "DEBUG: $func string after [$$stringRef]\n";
}

sub _clear {

	system("clear");
}

sub mymkpath {

	my $dir = shift;
	my $func = (caller(0))[3];
	
	# reset $@
	$@="";
	eval { mkpath ( $dir)};
	
	if( $@) {
	        chomp $@;
	        confess "$func: was not able to create dir [$dir], \$@ [$@].";
	}
}

1;
