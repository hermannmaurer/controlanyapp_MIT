#! /bin/perl

use strict; use warnings;
use File::Copy;

my $template="/opt/CONTROL/controlanyapp_MIT.d/deployments/template/CONTROL_TEMPLATE.txt";

sub display_usage {

        my $error = shift;

        print  <<END;

  Usage: $0 filename

  filename       Name of CONTROL TEMPLATE copy

END
        print "  Error [$error]\n" if defined $error;

        exit(0);
}

if( @ARGV<1) {

	display_usage( "Just miss the filename argument");
}

my $filename=$ARGV[0];


my( $result, $response);
{ #sequence

	if( -e $filename) {
		$result=0;
		$response="file [$filename] existiert bereits";
		last;
	}

	$result = copy( $template, $filename);
	if( ! $result) {
		$response = $!;
		last;
	}

	# next step
	$response = qx(chmod u+x $filename 2>&1);
	$result = ! $?;
}	
	

if( $result) {
	print "done!\n";
	exit 0;
} else {
	print "copy failed, response [$response]\n";
	exit 1;
}
