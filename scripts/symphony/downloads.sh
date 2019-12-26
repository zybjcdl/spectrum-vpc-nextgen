#!/bin/bash
ROLE=$1
LOG_FILE=/root/logs/download-$ROLE.log

function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start download script for $ROLE ..."

SCRIPTS_URI="https://raw.githubusercontent.com/zybjcdl/spectrum-vpc-nextgen/master/scripts/symphony"
INSTALLER_URI="http://52.117.200.197/suites/symphony/symeval-7.3.0.0_x86_64.bin"
ENTITLEMENT_URI=$2

LOG "wget -nv -nH -c --no-check-certificate -O symeval-7.3.0.0_x86_64.bin $INSTALLER_URI"
wget -nv -nH -c --no-check-certificate -O /root/installer/sym_x86_64.bin $INSTALLER_URI

LOG "wget -nv -nH -c --no-check-certificate -O /root/installer/pre-install.sh $SCRIPTS_URI/pre-install.sh"
wget -nv -nH -c --no-check-certificate -O /root/installer/pre-install.sh $SCRIPTS_URI/pre-install.sh?token=AFAYWK77HQRF7QZJFCCEOX26ARQWC

LOG "wget -nv -nH -c --no-check-certificate -O /root/installer/install.sh $SCRIPTS_URI/install.sh"
wget -nv -nH -c --no-check-certificate -O /root/installer/install.sh $SCRIPTS_URI/install.sh?token=AFAYWK77HQRF7QZJFCCEOX26ARQWC

LOG "wget -nv -nH -c --no-check-certificate -O /root/installer/clean.sh $SCRIPTS_URI/clean.sh"
wget -nv -nH -c --no-check-certificate -O /root/installer/clean.sh $SCRIPTS_URI/clean.sh?token=AFAYWK77HQRF7QZJFCCEOX26ARQWC

LOG "wget -nv -nH -c --no-check-certificate -O /root/installer/post-install.sh $SCRIPTS_URI/post-install.sh"
wget -nv -nH -c --no-check-certificate -O /root/installer/post-install.sh $SCRIPTS_URI/post-install.sh?token=AFAYWK77HQRF7QZJFCCEOX26ARQWC

if [ "$ROLE" == "master" ]
then
    LOG "wget -nv -nH -c --no-check-certificate -O /tmp/sym_adv_ev_entitlement.dat $ENTITLEMENT_URI"
    wget -nv -nH -c --no-check-certificate -O /tmp/sym_adv_entitlement.dat $ENTITLEMENT_URI

fi

chmod u+x /root/installer/*.sh

LOG "Complete download script for $ROLE."
