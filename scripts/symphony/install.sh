#!/bin/bash

export ROLE=$1
export CLUSTERNAME=$5

export CLUSTERADMIN=egoadmin
export SIMPLIFIEDWEM=N
export IBM_SPECTRUM_SYMPHONY_LICENSE_ACCEPT=Y
export BASEPORT=14899
if [ "$ROLE" == "compute" ]
then
    export EGOCOMPUTEHOST=Y
fi

LOG_FILE=/root/logs/install-$ROLE.log
function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start install.sh for $ROLE ..."

export >> "$LOG_FILE"

LOG "Start to install Symphony ..."
chmod u+x /root/installer/sym_x86_64.bin
/root/installer/sym_x86_64.bin --quiet >> "$LOG_FILE"

LOG "Complete install.sh for $ROLE."
