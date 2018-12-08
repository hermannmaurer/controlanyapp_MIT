#! /bin/bash

set -x

cat <<END
+++++++++++++++++++++++++
+ INSATLL CONTROLANYAPP + 
+++++++++++++++++++++++++

END

# handle workingdir
workingdir=$(dirname $0)
cd $workingdir

date=$(date +%Y%m%dT%H%M%S)

function check {

        echo "<<check>>"

}

function preparation {

        echo "<<preparation>>"

}

function install {

        echo "<<install>>"

}

function deploy {

        echo "<<deploy>>"

        find . -name deploy.sh | while read line; do

                set +x
                echo "---------------"
                set -x
                $line
                if [ "$?" != 0  ]; then
                        return 1;
                fi;
        done
}

function success {

        cat <<END
#######

SUCCESS

#######
END
        exit 0;
}

function failure {

        cat <<END
#######

FAILURE

#######
END
        exit 1;
}

check && preparation && install && deploy && success || failure

