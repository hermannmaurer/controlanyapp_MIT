package Control::ScriptConnector;

use strict; use warnings;

use Data::Dumper;
use Control::Control;

END {

	my $id=$main::ID;
	my $tasks=\@main::TASKS;
	my $logPath=$main::LOGPATH;

	my $obj=new Control::Control( $id, $tasks, $logPath);
        $obj->start();
}

1;
