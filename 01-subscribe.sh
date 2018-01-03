#!/bin/bash

#
# subscribe and update system
#

USERNAME="PUT YOUR RHSM USER NAME HERE"
PASSWD='PUT YOUR RHSM PASSWORD HERE'

# Insert your subscription manager pool id here, if known.  Otherwise,
# this script will try to dynamically determine the pool id.
SM_POOL_ID='PUT YOUR RHSM POOL ID HERE'

subscription-manager register --username $USERNAME --password $PASSWD

if [ "x${SM_POOL_ID}" = "x" ]
then
  SM_POOL_ID=`subscription-manager list --available | \
      grep 'Subscription Name:\|Pool ID:\|System Type' | \
      grep -B2 'Physical' | \
      grep -A1 'Red Hat Satellite Employee Subscription' | \
      grep 'Pool ID:' | awk '{print $3}'`

  # exit if none found
  if [ "x${SM_POOL_ID}" = "x" ]
  then
    echo "No subcription manager pool id found.  Exiting"
    exit 1
  fi
fi

# configure RHSM
subscription-manager attach --pool=$SM_POOL_ID
subscription-manager repos --disable='*'
subscription-manager repos --enable=rhel-7-server-rpms

# apply all updates
yum -y update
yum -y install java-1.8.0-openjdk-devel java-1.8.0-openjdk
yum -y clean all

# add bcfips provider
cp bc-fips-1.0.1.jar /usr/lib/jvm/jre-1.8.0-openjdk/lib/ext/

# set securerandom.source to non-blocking
sed -i 's/^\(securerandom.source=file:\/dev\/\)..*/\1urandom/g' \
    /usr/lib/jvm/jre-1.8.0-openjdk/lib/security/java.security

# reboot
systemctl reboot

