#!/bin/bash

IP_ADDR='PUT SERVER IP ADDRESS HERE'

# create the private key

cd /root/ca
openssl genrsa -aes256 \
    -passout pass:secretpassword \
    -out intermediate/private/appserver.$IP_ADDR.nip.io.key.pem 2048
chmod 400 intermediate/private/appserver.$IP_ADDR.nip.io.key.pem

# create the cert

openssl req -config intermediate/openssl.conf -new -sha256 \
    -passin pass:secretpassword \
    -key intermediate/private/appserver.$IP_ADDR.nip.io.key.pem \
    -out intermediate/csr/appserver.$IP_ADDR.nip.io.csr.pem \
    -subj "/C=US/ST=NC/L=Raleigh/O=Red Hat/OU=Public Sector/CN=appserver.$IP_ADDR.nip.io"

# sign the cert with the intermediate ca

openssl ca -config intermediate/openssl.conf \
    -batch -passin pass:secretpassword \
    -extensions server_cert -days 375 -notext -md sha256 \
    -in intermediate/csr/appserver.$IP_ADDR.nip.io.csr.pem \
    -out intermediate/certs/appserver.$IP_ADDR.nip.io.cert.pem
chmod 444 intermediate/certs/appserver.$IP_ADDR.nip.io.cert.pem

# verify the certificate

openssl x509 -noout -text \
    -in intermediate/certs/appserver.$IP_ADDR.nip.io.cert.pem

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
    intermediate/certs/appserver.$IP_ADDR.nip.io.cert.pem

