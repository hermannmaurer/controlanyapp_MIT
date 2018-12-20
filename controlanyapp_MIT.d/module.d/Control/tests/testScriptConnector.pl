#! /bin/perl

use strict; use warnings;

BEGIN {
	use File::Basename;
        # Change to working dir
        my $rootdir = dirname( $0);
        chdir $rootdir; # in case rootdir adjustment should happen
}

use lib qw(. ../..);
use Control::ScriptConnector;

################
# SETTINGS BEGIN
# our( $ID,@TASKS,$LOGPATH)

#our $ID="TESTSCRIPTCONNECTOR";

my $service="ntp.service"; # specify your systemctl service

our @TASKS= (
	#key       => [Safety question, task to execute on shell]
	#falsetest => [0, qq(false)],
	#truetest  => [0, qq(true)],
	start      => [1, qq(systemctl start   $service), 'N/A'],
	stop       => [1, qq(systemctl stop    $service)],
	status     => [0, qq(systemctl status  $service)],
	restart    => [1, qq(systemctl restart $service)],
	follow     => [0, qq(journalctl -b -ef -u $service)],
	dump       => [0, qq(journalctl -b -e -u  $service)],
	catService => [0, qq(systemctl cat     $service)],
	echoTest   => [0, qq(echo echoTest)],
	echoTest1   => [0, qq(echo echoTest1)],
	echoTest2   => [0, qq(echo echoTest2)],
	echoTest3   => [0, qq(echo echoTest3)],
);

#our $LOGPATH="/var/log/controlanyapp.d/$ID.log";

# SETTINGS END
################
