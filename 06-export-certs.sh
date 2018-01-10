#!/bin/bash

IP_ADDR='PUT SERVER IP ADDRESS HERE'

# export server cert
openssl pkcs12 -export \
    -passin 'pass:admin1jboss!' \
    -passout 'pass:admin1jboss!' \
    -chain \
    -in ca/intermediate/certs/appserver.$IP_ADDR.nip.io.cert.pem \
    -inkey ca/intermediate/private/appserver.$IP_ADDR.nip.io.key.pem \
    -CAfile ca/intermediate/certs/ca-chain.cert.pem \
    -name appserver \
    -out server.p12

# export client cert
openssl pkcs12 -export \
    -passin 'pass:admin1jboss!' \
    -passout 'pass:admin1jboss!' \
    -chain \
    -in ca/intermediate/certs/client.cert.pem \
    -inkey ca/intermediate/private/client.key.pem \
    -CAfile ca/intermediate/certs/ca-chain.cert.pem \
    -name client \
    -out client.p12
