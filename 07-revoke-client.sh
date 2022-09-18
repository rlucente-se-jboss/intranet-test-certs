#!/bin/bash

. $(dirname $0)/demo.conf

echo
echo "************************************************************************"
echo "          Running: $0"
echo "************************************************************************"
echo

# revoke the client cert
${OPENSSL} ca -config ca/intermediate/openssl.conf \
      -passin "$OPENSSL_DEFAULT_PASSWORD" \
      -revoke ca/intermediate/certs/client.cert.pem

# create the CRL
${OPENSSL} ca -config ca/intermediate/openssl.conf \
    -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -gencrl -out ca/intermediate/crl/crl.pem

# make CRL available in DER format
${OPENSSL} crl -inform PEM -in ca/intermediate/crl/crl.pem \
    -outform DER -out ca/intermediate/crl/intermediate-ca.crl

# verify the intermediate CA CRL
${OPENSSL} crl -in ca/intermediate/crl/crl.pem -noout -text

echo Verify the revoked client certificate against the CA cert chain and CRL
echo
cat ca/intermediate/certs/ca-chain.cert.pem ca/intermediate/crl/crl.pem > crl_chain.pem
${OPENSSL} verify -crl_check -CAfile crl_chain.pem ca/intermediate/certs/client.cert.pem
echo

echo "The generated certificates include a CRL Distribution Point.  You"
echo "can make this available (assuming you have python3 installed) using:"
echo
echo "    sudo python3 -m http.server 80"
echo
