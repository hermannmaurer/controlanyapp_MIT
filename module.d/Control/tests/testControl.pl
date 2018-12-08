#! /usr/bin/perl

use strict; use warnings;
use Data::Dumper;

BEGIN {
	use File::Basename;
	# Change to working dir
	my $rootdir = dirname( $0);
	chdir $rootdir; # in case rootdir adjustment should happen
}

use lib qw(. ../..);
use Control::Control;

################
# SETTINGS BEGIN
# our( $ID,@TASKS,$LOGPATH)

our $ID="TESTCONTROL";

my $service="my.service"; # specify your systemctl service

our @TASKS= (
	#key       => [Safety question, task to execute on shell]
	#falsetest => [0, qq(false)],
	#truetest  => [0, qq(true)],
	start      => [1, qq(systemctl start   $service)],
	stop       => [1, qq(systemctl stop    $service)],
	status     => [0, qq(systemctl status  $service)],
	restart    => [1, qq(systemctl restart $service)],
	follow     => [0, qq(journalctl -b -ef -u $service)],
	dump       => [0, qq(journalctl -b -e -u  $service)],
	catService => [0, qq(systemctl cat     $service)],
	echoTest   => [0, qq(echo echoTest)],
);

our $LOGPATH="/var/log/controlanyapp.d/$ID.log";

# SETTINGS END
################

sub test1 {

	my $obj=new Control::Control( $ID, \@TASKS, $LOGPATH);	
	$obj->start();
}

############
# MAIN START

test1();

# MAIN END
############

