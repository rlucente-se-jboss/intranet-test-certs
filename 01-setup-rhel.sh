#!/usr/bin/env bash

. $(dirname $0)/demo.conf

echo
echo "************************************************************************"
echo "          Running: $0"
echo "************************************************************************"
echo

[[ $EUID -ne 0 ]] && exit_on_error "Must run as root"

##
## Set hostname
##

hostnamectl set-hostname $SERVER_FQDN.

##
## Register the system
##

subscription-manager register \
    --username "$RHSM_USER" --password "$RHSM_PASS" \
    || exit_on_error "Unable to register subscription"
subscription-manager role --set="Red Hat Enterprise Linux Server"
subscription-manager service-level --set="Self-Support"
subscription-manager usage --set="Development/Test"
subscription-manager attach

##
## Update the system
##

dnf -y update

##
## Install needed tools
##

dnf -y install nss-tools openssl tpm2-tools

##
## Clean up
##

dnf -y clean all

