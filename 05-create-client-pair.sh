#!/bin/bash

. $(dirname $0)/demo.conf

echo
echo "************************************************************************"
echo "          Running: $0"
echo "************************************************************************"
echo

#
# adjust user principal name within subject alternative name
# msUPN = 1.3.6.1.4.1.311.20.2.3
#
sed -i.bak "s/\(otherName:msUPN;UTF8:\)..*/\1$CLIENT_UPN/g" \
    $WORKDIR/ca/intermediate/openssl.conf

# create the private key

cd $WORKDIR/ca
${OPENSSL} genrsa -aes256 \
    -passout "$OPENSSL_DEFAULT_PASSWORD" \
    -out intermediate/private/$CLIENT_USERNAME.key.pem 2048
chmod 400 intermediate/private/$CLIENT_USERNAME.key.pem

# create the cert

${OPENSSL} req -config intermediate/openssl.conf -new -sha256 \
    -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -key intermediate/private/$CLIENT_USERNAME.key.pem \
    -out intermediate/csr/$CLIENT_USERNAME.csr.pem \
    -subj "$SUBJECT_CLIENT"

# sign the cert with the intermediate ca

${OPENSSL} ca -config intermediate/openssl.conf \
    -batch -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -extensions usr_cert -days 375 -notext -md sha256 \
    -in intermediate/csr/$CLIENT_USERNAME.csr.pem \
    -out intermediate/certs/$CLIENT_USERNAME.cert.pem
chmod 444 intermediate/certs/$CLIENT_USERNAME.cert.pem

# verify the certificate

${OPENSSL} x509 -noout -text \
    -in intermediate/certs/$CLIENT_USERNAME.cert.pem

${OPENSSL} verify -CAfile intermediate/certs/ca-chain.cert.pem \
    intermediate/certs/$CLIENT_USERNAME.cert.pem

