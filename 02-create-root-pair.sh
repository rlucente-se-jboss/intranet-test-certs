#!/usr/bin/env bash

. $(dirname $0)/demo.conf

# create directory structure
rm -fr $WORKDIR/ca $WORKDIR/*.p12 $WORKDIR/*.pem $WORKDIR/.pki
mkdir -p $WORKDIR/ca
cd $WORKDIR/ca
mkdir certs crl newcerts private

# create flat file database to track signed certs
chmod 700 private
touch index.txt
echo 1000 > serial

# create root CA configuration file
envsubst '$WORKDIR' < $WORKDIR/root-ca-openssl.conf > $WORKDIR/ca/openssl.conf

# create root key
openssl genrsa -aes256 \
    -passout "$OPENSSL_DEFAULT_PASSWORD" \
    -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

# create root certificate
openssl req -config openssl.conf \
    -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -key private/ca.key.pem \
    -new -x509 -days 7300 -sha256 -extensions v3_ca \
    -out certs/ca.cert.pem \
    -subj "/C=US/ST=NC/L=Raleigh/O=Red Hat/OU=Public Sector/CN=Red Hat Root CA Test"

chmod 444 certs/ca.cert.pem

# verify the root certificate
openssl x509 -noout -text -in certs/ca.cert.pem

