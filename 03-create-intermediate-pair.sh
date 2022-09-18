#!/usr/bin/env bash

. $(dirname $0)/demo.conf

echo
echo "************************************************************************"
echo "          Running: $0"
echo "************************************************************************"
echo

# create the intermediate pair

# prepare the directory
mkdir $WORKDIR/ca/intermediate
cd $WORKDIR/ca/intermediate
mkdir certs crl csr newcerts private
chmod 700 private

# create flat file database to track signed certs and crls
touch index.txt
echo 1000 > serial
echo 1000 > $WORKDIR/ca/intermediate/crlnumber

# create intermediate CA configuration file
envsubst '$WORKDIR$SERVER_DOMAIN' < $WORKDIR/intermediate-ca-openssl.conf > $WORKDIR/ca/intermediate/openssl.conf
cat >> $WORKDIR/ca/intermediate/openssl.conf <<END1
[server_alt_names]
DNS.1 = *.$SERVER_DOMAIN
DNS.2 = $SERVER_DOMAIN
DNS.3 = localhost
IP.1 = 127.0.0.1

END1

#
# set user principal name within subject alternative name
# msUPN = 1.3.6.1.4.1.311.20.2.3
#
sed -i.bak "s/CLIENT_SAN_HERE/otherName:msUPN;UTF8:$CLIENT_UPN/g" \
    $WORKDIR/ca/intermediate/openssl.conf

# create the intermediate key
cd $WORKDIR/ca
${OPENSSL} genrsa -aes256 \
   -passout "$OPENSSL_DEFAULT_PASSWORD" \
   -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem

# create the intermediate certificate
${OPENSSL} req -config intermediate/openssl.conf -new -sha256 \
    -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -key intermediate/private/intermediate.key.pem \
    -out intermediate/csr/intermediate.csr.pem \
    -subj "$SUBJECT_BASE/CN=Red Hat Intermediate CA Test"

${OPENSSL} ca -config openssl.conf -extensions v3_intermediate_ca \
    -batch -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -days 3650 -notext -md sha256 \
    -in intermediate/csr/intermediate.csr.pem \
    -out intermediate/certs/intermediate.cert.pem

chmod 444 intermediate/certs/intermediate.cert.pem

# verify the intermediate certificate
${OPENSSL} x509 -noout -text \
    -in intermediate/certs/intermediate.cert.pem
${OPENSSL} verify -CAfile certs/ca.cert.pem \
    intermediate/certs/intermediate.cert.pem

# the certificate chain file is the intermediate certificate
# concatenated with the root CA
cat intermediate/certs/intermediate.cert.pem \
    certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem

# create the empty CRL
${OPENSSL} ca -config intermediate/openssl.conf \
    -passin "$OPENSSL_DEFAULT_PASSWORD" \
    -gencrl -out intermediate/crl/crl.pem

${OPENSSL} crl -inform PEM -in intermediate/crl/crl.pem \
    -outform DER -out intermediate/crl/intermediate-ca.crl

# verify the intermediate CA CRL
${OPENSSL} crl -in intermediate/crl/crl.pem -noout -text

