#!/bin/bash

export ROLE=$1
export ADMIN_PASSWORD=`echo $3 | base64 -d`
export REMOTE_CONSOLE_SSH_KEY=`echo $4 | base64 -d`
export MASTER_HOSTNAME=$6
export MASTER_PRIVATE_IP=$7

export MASTER_HOSTNAME_SHORT=`echo $MASTER_HOSTNAME | cut -d '.' -f 1`

LOG_FILE=/root/logs/pre-install-$ROLE.log
function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start pre-install.sh for $ROLE ..."

export >> "$LOG_FILE"

LOG "Add remote console SSH key"
echo $REMOTE_CONSOLE_SSH_KEY >> /root/.ssh/authorized_keys

chmod 600 /root/.ssh/id_rsa
chmod 644 /root/.ssh/id_rsa.pub
if [ "$ROLE" == "master" ]
then
    rm -f /root/.ssh/compute-host.pub
else
    LOG "Add SSH key of master to compute"
    cat /root/.ssh/master-host.pub >> /root/.ssh/authorized_keys
    rm -f /root/.ssh/master-host.pub

    LOG "Set /etc/hosts"
    echo $MASTER_PRIVATE_IP $MASTER_HOSTNAME $MASTER_HOSTNAME_SHORT >> /etc/hosts
fi

LOG "Create user egoadmin"
echo $ADMIN_PASSWORD > /tmp/password_input
echo $ADMIN_PASSWORD >> /tmp/password_input
echo  >> /tmp/password_input
useradd -g wheel -m egoadmin
passwd egoadmin < /tmp/password_input >> "$LOG_FILE"
id egoadmin >> "$LOG_FILE"
rm -f /tmp/password_input

if [ "$ROLE" == "master" ]
then
    DEPENDENCY="bc gettext bind-utils ed net-tools dejavu-serif-fonts httpd"
else
    DEPENDENCY="bc gettext bind-utils ed net-tools dejavu-serif-fonts"
fi
LOG "yum -y install $DEPENDENCY"
yum -y install $DEPENDENCY >> "$LOG_FILE"

LOG "Complete pre-install.sh for $ROLE."
