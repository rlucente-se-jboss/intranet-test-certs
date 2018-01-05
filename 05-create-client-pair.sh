#!/bin/bash

# create the private key

cd /root/ca
openssl genrsa -aes256 \
    -passout 'pass:admin1jboss!' \
    -out intermediate/private/client.key.pem 2048
chmod 400 intermediate/private/client.key.pem

# create the cert

openssl req -config intermediate/openssl.conf -new -sha256 \
    -passin 'pass:admin1jboss!' \
    -key intermediate/private/client.key.pem \
    -out intermediate/csr/client.csr.pem \
    -subj "/C=US/ST=NC/L=Raleigh/O=Red Hat/OU=Public Sector/CN=Some User"

# sign the cert with the intermediate ca

openssl ca -config intermediate/openssl.conf \
    -batch -passin 'pass:admin1jboss!' \
    -extensions usr_cert -days 375 -notext -md sha256 \
    -in intermediate/csr/client.csr.pem \
    -out intermediate/certs/client.cert.pem
chmod 444 intermediate/certs/client.cert.pem

# verify the certificate

openssl x509 -noout -text \
    -in intermediate/certs/client.cert.pem

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
    intermediate/certs/client.cert.pem

