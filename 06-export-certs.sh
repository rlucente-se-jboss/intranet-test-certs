#!/bin/bash

. $(dirname $0)/demo.conf

# export server cert
openssl pkcs12 -export \
    -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -passout "$OPENSSL_DEFAULT_PASSWORD" \
    -in ca/intermediate/certs/$SERVER_FQDN.cert.pem \
    -inkey ca/intermediate/private/$SERVER_FQDN.key.pem \
    -CAfile ca/intermediate/certs/ca-chain.cert.pem \
    -name $SERVER_NAME \
    -out server.p12

# export client cert
openssl pkcs12 -export \
    -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -passout "$OPENSSL_DEFAULT_PASSWORD" \
    -in ca/intermediate/certs/client.cert.pem \
    -inkey ca/intermediate/private/client.key.pem \
    -CAfile ca/intermediate/certs/ca-chain.cert.pem \
    -name client \
    -out client.p12

# make root CA and intermediate CA available
ln -s ca/certs/ca.cert.pem .
ln -s ca/intermediate/certs/intermediate.cert.pem .

# make ca-chain cert available
ln -s ca/intermediate/certs/ca-chain.cert.pem .

# make client cert available
ln -s ca/intermediate/certs/client.cert.pem .

