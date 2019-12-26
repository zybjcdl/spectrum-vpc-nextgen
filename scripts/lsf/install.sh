#!/bin/bash

export ROLE=$1
export ADMIN_PASSWORD=`echo $3 | base64 -d`
export CLUSTERNAME=$5
export NUM_COMPUTES=$8
export COMPUTE_HOSTNAME=$9
export COMPUTE_PRIVATE_IP=${10}


array_compute_host=(${COMPUTE_HOSTNAME//,/ })

LOG_FILE=/root/logs/install-$ROLE.log
function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start install.sh for $ROLE ..."

export >> "$LOG_FILE"

if [ "$ROLE" == "master" ]
then
    LOG "Extract deployer ..."
    chmod 744 /root/installer/lsfsent-x86_64.bin
    echo "1" > /root/installer/select_yes
    echo  >> /root/installer/select_yes
    /root/installer/lsfsent-x86_64.bin < /root/installer/select_yes >> "$LOG_FILE"
    rm -f /root/installer/select_yes

    cd /opt/ibm/lsf_installer/playbook

    LOG "Modify lsf-config.yml"
    sed -i 's/my_cluster_name: myCluster/my_cluster_name: '${CLUSTERNAME}'/' lsf-config.yml

    LOG "Modify lsf-inventory"
#    sed -i '/\[LSF_Servers\]/a\'$COMPUTE_HOSTNAME_SHORT'' lsf-inventory
    for((i=1;i<=$NUM_COMPUTES;i++));
    do
       sed -i '/\[LSF_Servers\]/a\'${array_compute_host[i-1]}'' lsf-inventory
    done

    LOG "Perform pre-install checking"
    ansible-playbook -i lsf-inventory lsf-config-test.yml>/root/logs/lsf-config-test.log
    result=`cat /root/logs/lsf-config-test.log|grep 'failed='|sed -n 's/^.*failed=//;p'|grep '[1-9]'`
    if [ -z "$result" ]
    then
        LOG "Config test passed, please check /root/logs/lsf-config-test.log for detail."
    else
        LOG "Found error in config test, please check /root/logs/lsf-config-test.log for detail."
        exit -1
    fi
    ansible-playbook -i lsf-inventory lsf-predeploy-test.yml>/root/logs/lsf-predeploy-test.log
    result=`cat /root/logs/lsf-predeploy-test.log|grep 'failed='|sed -n 's/^.*failed=//;p'|grep '[1-9]'`
    if [ -z "$result" ]
    then
        LOG "Pre-deploy test passed, please check /root/logs/lsf-predeploy-test.log for detail."
    else
        LOG "Found error in pre-deploy test, please check /root/logs/lsf-predeploy-test.log for detail."
        exit -1
    fi

    LOG "Install LSF"
    ansible-playbook -i lsf-inventory lsf-deploy.yml>/root/logs/lsf-deploy.log
    result=`cat /root/logs/lsf-deploy.log|grep 'failed='|sed -n 's/^.*failed=//;p'|grep '[1-9]'`
    if [ -z "$result" ]
    then
        LOG "Install LSF successfully, please check /root/logs/lsf-deploy.log for detail."
    else
        LOG "Found error in deploy, please check /root/logs/lsf-deploy.log for detail."
        exit -1
    fi

    LOG "Set password for lsfadmin"
    echo "$ADMIN_PASSWORD" > /root/lsfadmin_password
    echo "$ADMIN_PASSWORD" >> /root/lsfadmin_password
    echo  >> /root/lsfadmin_password
    passwd lsfadmin < /root/lsfadmin_password >> "$LOG_FILE"
    rm -f /root/lsfadmin_password
fi

LOG "Complete install.sh for $ROLE."
