#!/bin/bash

. $(dirname $0)/demo.conf

echo
echo "************************************************************************"
echo "          Running: $0"
echo "************************************************************************"
echo

# export server cert
${OPENSSL} pkcs12 -export \
    -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -passout "$OPENSSL_DEFAULT_PASSWORD" \
    -in ca/intermediate/certs/$SERVER_FQDN.cert.pem \
    -inkey ca/intermediate/private/$SERVER_FQDN.key.pem \
    -CAfile ca/intermediate/certs/ca-chain.cert.pem \
    -name $SERVER_NAME \
    -out server.p12

# export client cert
${OPENSSL} pkcs12 -export \
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

# make client cert available
ln -s ca/intermediate/certs/client.cert.pem .

# make CRL available in DER format
ln -s ca/intermediate/crl/intermediate-ca.crl .

echo Verify the server and client certificates against the CA cert chain and CRL
echo
cat ca/intermediate/certs/ca-chain.cert.pem ca/intermediate/crl/crl.pem > crl_chain.pem
${OPENSSL} verify -crl_check -CAfile crl_chain.pem ca/intermediate/certs/$SERVER_FQDN.cert.pem
${OPENSSL} verify -crl_check -CAfile crl_chain.pem ca/intermediate/certs/client.cert.pem
echo

echo "The generated certificates include a CRL Distribution Point.  You"
echo "can make this available (assuming you have python3 installed) using:"
echo
echo "    sudo python3 -m http.server 80"
echo
