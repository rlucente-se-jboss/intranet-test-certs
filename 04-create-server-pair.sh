#!/usr/bin/env bash

. $(dirname $0)/demo.conf

echo
echo "************************************************************************"
echo "          Running: $0"
echo "************************************************************************"
echo

# create the private key

cd $WORKDIR/ca
${OPENSSL} genrsa -aes256 \
    -passout "$OPENSSL_DEFAULT_PASSWORD" \
    -out intermediate/private/$SERVER_FQDN.key.pem 2048
chmod 400 intermediate/private/$SERVER_FQDN.key.pem

# create the cert

${OPENSSL} req -config intermediate/openssl.conf -new -sha256 \
    -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -key intermediate/private/$SERVER_FQDN.key.pem \
    -out intermediate/csr/$SERVER_FQDN.csr.pem \
    -subj "/C=US/ST=NC/L=Raleigh/O=Red Hat/OU=Public Sector/CN=*.$SERVER_DOMAIN"

# sign the cert with the intermediate ca

${OPENSSL} ca -config intermediate/openssl.conf \
    -batch -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -extensions server_cert -days 375 -notext -md sha256 \
    -in intermediate/csr/$SERVER_FQDN.csr.pem \
    -out intermediate/certs/$SERVER_FQDN.cert.pem
chmod 444 intermediate/certs/$SERVER_FQDN.cert.pem

# verify the certificate

${OPENSSL} x509 -noout -text \
    -in intermediate/certs/$SERVER_FQDN.cert.pem

${OPENSSL} verify -CAfile intermediate/certs/ca-chain.cert.pem \
    intermediate/certs/$SERVER_FQDN.cert.pem

