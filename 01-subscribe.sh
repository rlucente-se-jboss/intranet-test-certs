#!/bin/bash

#
# subscribe and update system
#

. $(dirname $0)/demo.conf

# set hostname
hostnamectl set-hostname $SERVER_FQDN.

# configure RHSM
subscription-manager register --username $RHSM_USERNAME --password $RHSM_PASSWD
subscription-manager attach --pool=$RHSM_POOL_ID
subscription-manager repos --disable='*'
subscription-manager repos --enable=rhel-7-server-rpms

# apply all updates
yum -y update
yum -y install java-1.8.0-openjdk-devel java-1.8.0-openjdk unzip
yum -y clean all

# reboot
systemctl reboot

