#! /bin/bash

set -x

# handle workingdir
workingdir=$(dirname $0)
cd $workingdir

date=$(date +%Y%m%dT%H%M%S)

function check {

	echo "<<check>>"
}

function backup {

	echo "<<backup>>"
}

function deploy {

	echo "<<deploy>>"

	template="CONTROL_TEMPLATE.pl"
	#cp "$template" /usr/local/bin &&
	#cp "$template" /usr/local/sbin &&
	#chmod 755 "/usr/local/bin/$template"
	[ -d /usr/local/bin ] &&
	[ -d /usr/local/sbin ] &&
	ln -sf "/opt/CONTROL/controlanyapp_MIT.d/deployments/template/$template" /usr/local/bin &&
	ln -sf "/opt/CONTROL/controlanyapp_MIT.d/deployments/template/$template" /usr/local/sbin &&
	chmod 755 "$template"
}

function success {

	set +x
	cat <<END
#######

SUCCESS

#######
END
	set -x
	exit 0;
}

function failure {

	set +x
	cat <<END
#######

FAILURE

#######
END
	set -x
	exit 1;
}

check && backup && deploy && success || failure
