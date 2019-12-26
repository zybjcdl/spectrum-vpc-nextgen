#!/bin/bash

rm -fr /root/installer

if [ "$1" == "master" ]
then
    rm -fr /tmp/sym_adv_entitlement.dat
fi

sed -i '/deployer@deployer/d' /root/.ssh/authorized_keys
