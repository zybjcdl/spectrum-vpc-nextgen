#!/bin/bash

export ROLE=$1
export MASTER_HOSTNAME=$6

export MASTER_HOSTNAME_SHORT=`echo $MASTER_HOSTNAME | cut -d '.' -f 1`

LOG_FILE=/root/logs/post-install-$ROLE.log
function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

function EGOSH_LOGON()
{
    LOG "Try to logon egosh ..."
    RETRY=0
    while [ $RETRY -lt 30 ]
    do
        sleep 10
        USER_LOGON=`egosh user logon -u Admin -x Admin 2>&1`
        if [ "$USER_LOGON" == "Logged on successfully" ]
        then
            LOG "Logon egosh successfully."
            return 0
        else
            RETRY=`expr $RETRY + 1`
            LOG "Retry logon egosh ... $RETRY"
        fi
    done

    LOG "Failed to logon egosh!"
    return 1
}

function IS_COMPUTE_JOIN()
{
    LOG "Try to list resource ..."
    RETRY=0
    while [ $RETRY -lt 30 ]
    do
        sleep 10
        RESOURCE_LIST=`egosh resource list -l | grep $1`
        if [ -n "$RESOURCE_LIST" ]
        then
            LOG "$1 is in resource list."
            return 0
        else
            RETRY=`expr $RETRY + 1`
            LOG "Retry list resource ... $RETRY"
        fi
    done

    LOG "$1 failed to join the cluster!"
    return 1
}

LOG "Start post-install.sh for $ROLE ..."

export >> "$LOG_FILE"

LOG "Post configure for cluster ..."
source /opt/ibm/spectrumcomputing/profile.platform
if [ "$ROLE" == "master" ]
then
    chown egoadmin:wheel /tmp/sym_adv_entitlement.dat
fi
egosetrc.sh >> "$LOG_FILE"
egosetsudoers.sh >> "$LOG_FILE"
LOG "Join the cluster"
su egoadmin -c "egoconfig join $MASTER_HOSTNAME -f" >> "$LOG_FILE"
if [ "$ROLE" == "master" ]
then
    LOG "Set entitlement"
    su egoadmin -c "egoconfig setentitlement /tmp/sym_adv_entitlement.dat" >> "$LOG_FILE"
fi
egosh ego start  >> "$LOG_FILE"

LOG "Wait EGO service start ..."
EGOSH_LOGON
EGO_SERVICE_STARTED=$?
if [ $EGO_SERVICE_STARTED -eq 1 ]
then
    LOG "Failed to start EGO service, exit!"
    return 1
fi
LOG "EGO service has been started."

if [ "$ROLE" == "compute" ]
then
    IS_COMPUTE_JOIN `echo $HOSTNAME | cut -d '.' -f 1`
    COMPUTE_JOINED=$?
    if [ $COMPUTE_JOINED -eq 1 ]
    then
        return 1
    fi
    LOG "Complete post-install.sh for $ROLE."
    return 0
fi

LOG "Complete post-install.sh for $ROLE."
