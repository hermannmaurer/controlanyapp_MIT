#!/bin/bash

#########################################
# SNMPGW Self-Installer Script
#########################################
#
# Author:  Hermann Maurer
# Email:   hmfetch@gmail.com
#
# COPYRIGHT (c) 2018 Hermann Maurer
#
#########################################
VERSION="1.00"
#########################################
# cp selfInstallerTemplate.sh SNMPGW_1_0_Installer.sh
# cat SNMPGW_1_0_20181001_150429_1.06.tar.gz >> SNMPGW_1_0_Installer.sh

ID="CONTROL"
IGNORDELIVERYDIR=$1;
###
### SAFE MODE
###
echo
echo "Installation of $ID: Continue - press <c>, Quit - press <q>,"
read -n 1 -s CSQA
if test "$CSQA" == "c"; then
        echo continue
elif test "$CSQA" == "q"; then
        echo quit
        exit
else
	echo quit
	exit
fi

cat <<__END__

##########################################

  Started CONTROL Self-Extracting Script

##########################################

__END__

set -x

# use absolute path
ROOTDIR="/opt/CONTROL"
LOGDIR="$ROOTDIR/install_log.d"
DELIVERYDIR="$ROOTDIR/installer.d"
DATE=$(date +%Y.%m.%dT%H:%M:%S)
LOGFILE="$LOGDIR/${ID}_${DATE}.log"
INSTALLDIR="controlanyapp_MIT.d"
INSTALLSCRIPT="$ROOTDIR/$INSTALLDIR/install.sh"

function preconditions {

	set +x
	echo "########################"
	echo "INSTALLER: preconditions"
	echo "########################"
	set -x

	if [ "$(uname -o)" != 'Cygwin' ]; then
		if [ "$(id -u)" != "0" ]; then
		
			echo "need root user for execution: sudo $0"
			return 1;
		fi
	fi

	mkdir -p "$ROOTDIR" && \
	mkdir -p "$LOGDIR" && \
	mkdir -p "$DELIVERYDIR"
}

function extract {

	set +x
	echo "##################"
	echo "INSTALLER: extract"
	echo "##################"
	set -x

	archive=$(grep --text --line-number 'ARCHIVE:$' $0 | cut -d: -f1) && \
	tail -n +$((archive + 1)) $0 | gzip -vdc - | tar -C "$ROOTDIR" -xvf - > /dev/null
}

function install {

	set +x
	echo "##################"
	echo "INSTALLER: install"
	echo "##################"
	set -x

	if [ "$IGNORDELIVERYDIR" != "" ]; then

		echo "IGNOREDELIVERYDIR";
		$INSTALLSCRIPT
	else

		[ ${#INSTALLDIR} -ne 0 ] && $INSTALLSCRIPT && \
		mv $0 "$DELIVERYDIR"
	fi
}

function success {

        cat <<END
#######

SUCCESS

#######

Installation complete!

END
        exit 0;
}

function failure {

        cat <<END
#######

FAILURE

#######

Please provde the log file [$LOGFILE] for troubleshooting.

END
        exit 1;
}

############
# MAIN START


mkdir -p "$LOGDIR" && \
( preconditions && extract && install && success || failure ) 2>&1 | tee "$LOGFILE"
exit
# MAIN END
############

ARCHIVE:
