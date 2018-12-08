#! /bin/bash

VERSION=$(cat VERSION)
#PROJECT=$(dirs | cut -d/ -f2)
PROJECT=$(dirs | awk -F/ '{print $(NF)}')
echo "VERSION: $VERSION"
echo "PROJECT: $PROJECT"
cd ..
## don't exclude test.d
TARBALL="${PROJECT}_$(date +%Y%m%d_%H%M%S)_$VERSION.tgz"
OPTIONS+="--exclude log.d " # not used
tar -cvzf $TARBALL $PROJECT $OPTIONS


dir="$HOME/Dropbox/"
if [ -d "$dir" ]; then
	echo "finally move tarball to [$dir$TARBALL]"
	mv $TARBALL $dir;
else
        echo "pick up your tarball from [$(readlink -f $TARBALL)]"
fi
cd -
