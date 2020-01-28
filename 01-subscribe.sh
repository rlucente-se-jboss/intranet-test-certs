#!/bin/bash

#
# subscribe and update system
#

. $(dirname $0)/demo.conf

echo
echo "************************************************************************"
echo "          Running: $0"
echo "************************************************************************"
echo

# set hostname
hostnamectl set-hostname $SERVER_FQDN.

# configure RHSM
subscription-manager register --username $RHSM_USERNAME --password $RHSM_PASSWD
subscription-manager attach --pool=$RHSM_POOL_ID
subscription-manager repos --disable='*'

if [[ -n "$(grep 'release 7' /etc/redhat-release)" ]]
then
    subscription-manager repos --enable=rhel-7-server-rpms
elif [[ -n "$(grep 'release 8' /etc/redhat-release)" ]]
then
    subscription-manager repos \
        --enable=rhel-8-for-x86_64-baseos-rpms \
        --enable=rhel-8-for-x86_64-appstream-rpms
else
    echo "*** UNKNOWN OPERATING SYSTEM ***"
    exit 1
fi

# apply all updates
yum -y update

# install needed tools
yum -y install nss-tools openssl

# clean up and reboot
yum -y clean all
systemctl reboot

