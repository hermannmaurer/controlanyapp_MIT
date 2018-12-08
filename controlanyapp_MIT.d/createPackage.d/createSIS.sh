#! /bin/bash

#########################################
# createSIS.sh
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

#######################
# Handle workingdir
workingdir=$(dirname $0)
cd $workingdir

#######################
# Increase VERSIONMINOR
sed -r -i 's/([0-9]+)/echo $((\1+1))/e' ../VERSIONMINOR

#######################
# Preparations

SELFITEMPLATE=$(readlink -f selfInstallerTemplate.sh);

VERSIONMINOR=$(cat ../VERSIONMINOR)
#PROJECT=$(dirs | awk -F/ '{print $(NF)}')
cd ..
PROJECT=$(readlink -f . | awk -F/ '{print $(NF)}')
echo "PROJECT: $PROJECT"
echo "VERSIONMINOR: $VERSIONMINOR"
cd ..

################
# Create TARBALL

## don't exclude test.d
TARBALL="${PROJECT}_$(date +%Y%m%d_%H%M%S)_${VERSIONMINOR}.tar"
OPTIONS=""
OPTIONS+="--exclude log.d "
#tar -cvzf $TARBALL $PROJECT $OPTIONS;
tar -cvf $TARBALL $PROJECT $OPTIONS; gzip -9 $TARBALL

##############################
# Create SELF_INSTALLER-SCRIPT 

if [ -f "$SELFITEMPLATE" ]; then

	SELFISCRIPT="${PROJECT}_${VERSIONMINOR}_Installer.sh"
	cp "$SELFITEMPLATE" "$SELFISCRIPT" &&
	cat "$TARBALL.gz" >> "$SELFISCRIPT" &&
	chmod u+x "$SELFISCRIPT"
fi

#####################################
# Move to Archive if directory exists

dir="$HOME/Archive/"
if [ -d "$dir" ]; then
        echo "finally move tarball to [$dir$TARBALL.gz]"
        mv $TARBALL.gz $dir
        [ -f "$SELFITEMPLATE" ] && echo "finally move Self-Installer-Script to [$dir$SELFISCRIPT]" && \
	mv "$SELFISCRIPT" $dir
else
        echo "pick up your tarball from [$(readlink -f $TARBALL.gz)]"
        echo "pick up your Self-Extracting Script from [$(readlink -f $SELFISCRIPT)]"
fi
cd -

