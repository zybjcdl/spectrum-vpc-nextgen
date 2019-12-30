#!/bin/bash
ROLE=$1
LOG_FILE=/root/logs/download-$ROLE.log

function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start download script for $ROLE ..."


SCRIPTS_URI=$2/lsf
INSTALLER_URI="http://52.117.200.197/suites/lsf/lsfsent10.2.0.8-x86_64.bin"
ENTITLEMENT_URI=$3

LOG "wget -nv -nH -c --no-check-certificate -O /root/installer/pre-install.sh $SCRIPTS_URI/pre-install.sh"
wget -nv -nH -c --no-check-certificate -O /root/installer/pre-install.sh $SCRIPTS_URI/pre-install.sh

LOG "wget -nv -nH -c --no-check-certificate -O /root/installer/install.sh $SCRIPTS_URI/install.sh"
wget -nv -nH -c --no-check-certificate -O /root/installer/install.sh $SCRIPTS_URI/install.sh

LOG "wget -nv -nH -c --no-check-certificate -O /root/installer/clean.sh $SCRIPTS_URI/clean.sh"
wget -nv -nH -c --no-check-certificate -O /root/installer/clean.sh $SCRIPTS_URI/clean.sh

LOG "wget -nv -nH -c --no-check-certificate -O /root/installer/post-install.sh $SCRIPTS_URI/post-install.sh"
wget -nv -nH -c --no-check-certificate -O /root/installer/post-install.sh $SCRIPTS_URI/post-install.sh

if [ "$ROLE" == "master" ]
then
    LOG "wget -nv -nH -c --no-check-certificate -O lsfsent-x86_64.bin $INSTALLER_URI"
    wget -nv -nH -c --no-check-certificate -O /root/installer/lsfsent-x86_64.bin $INSTALLER_URI
    LOG "wget -nv -nH -c --no-check-certificate -O /tmp/lsf.entitlement $ENTITLEMENT_URI"
    wget -nv -nH -c --no-check-certificate -O /tmp/lsf.entitlement $ENTITLEMENT_URI
    chmod u+x /root/installer/*.sh
fi


LOG "Complete download script for $ROLE."
