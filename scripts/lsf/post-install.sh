#!/bin/bash

export ROLE=$1

LOG_FILE=/root/logs/post-install-$ROLE.log
function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Post configure for cluster ..."
source /opt/ibm/spectrumcomputing/profile.platform
if [ "$ROLE" == "master" ]
then
    source /opt/ibm/lsfsuite/lsf/conf/profile.lsf
    lsadmin limshutdown
    rm -f /opt/ibm/lsfsuite/lsf/conf/lsf.entitlement
    cp /tmp/lsf.entitlement /opt/ibm/lsfsuite/lsf/conf/lsf.entitlement
    lsadmin limstartup
fi

LOG "Complete post-install.sh for $ROLE."
