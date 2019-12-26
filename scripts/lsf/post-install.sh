#!/bin/bash

export ROLE=$1

LOG_FILE=/root/logs/post-install-$ROLE.log
function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Complete post-install.sh for $ROLE."
