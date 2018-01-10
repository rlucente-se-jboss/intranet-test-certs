#!/bin/bash

# create the intermediate pair

# prepare the directory
mkdir /root/ca/intermediate
cd /root/ca/intermediate
mkdir certs crl csr newcerts private
chmod 700 private

# create flat file database to track signed certs and crls
touch index.txt
echo 1000 > serial
echo 1000 > /root/ca/intermediate/crlnumber

# create intermediate CA configuration file
cp /root/intermediate-ca-openssl.conf /root/ca/intermediate/openssl.conf

# create the intermediate key
cd /root/ca
openssl genrsa -aes256 \
   -passout 'pass:admin1jboss!' \
   -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem

# create the intermediate certificate
openssl req -config intermediate/openssl.conf -new -sha256 \
    -passin 'pass:admin1jboss!' \
    -key intermediate/private/intermediate.key.pem \
    -out intermediate/csr/intermediate.csr.pem \
    -subj "/C=US/ST=NC/L=Raleigh/O=Red Hat/OU=Public Sector/CN=Red Hat Intermediate CA Test"

echo 'Enter passphrase for intermediate.key.pem (e.g. secretpassword)'
openssl ca -config openssl.conf -extensions v3_intermediate_ca \
    -batch -passin 'pass:admin1jboss!' \
    -days 3650 -notext -md sha256 \
    -in intermediate/csr/intermediate.csr.pem \
    -out intermediate/certs/intermediate.cert.pem

chmod 444 intermediate/certs/intermediate.cert.pem

# verify the intermediate certificate
openssl x509 -noout -text \
    -in intermediate/certs/intermediate.cert.pem
openssl verify -CAfile certs/ca.cert.pem \
    intermediate/certs/intermediate.cert.pem

# create the certificate chain file
cat intermediate/certs/intermediate.cert.pem \
    certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem

