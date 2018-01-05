#!/bin/bash

IP_ADDR='PUT SERVER IP ADDRESS HERE'

# initialize NSS database
mkdir -p $HOME/fipsdb
modutil -force -dbdir $HOME/fipsdb -create
modutil -force -dbdir $HOME/fipsdb -fips true

echo "Scripts assume NSS keystore password is admin1jboss!"
modutil -force -dbdir $HOME/fipsdb -changepw "NSS FIPS 140-2 Certificate DB"

# import root ca to keystore

keytool -importcert \
    -J-Djava.security.properties="$HOME"/java.security.properties \
    -keystore NONE \
    -alias root_ca \
    -file ca/certs/ca.cert.pem \
    -deststorepass 'admin1jboss!' \
    -storetype pkcs11

# export server cert

openssl pkcs12 -export \
    -passin 'pass:admin1jboss!' \
    -passout 'pass:admin1jboss!' \
    -in ca/intermediate/certs/appserver.$IP_ADDR.nip.io.cert.pem \
    -inkey ca/intermediate/private/appserver.$IP_ADDR.nip.io.key.pem \
    -CAfile ca/intermediate/certs/ca-chain.cert.pem \
    -name appserver \
    -out server.p12

# export client cert

openssl pkcs12 -export \
    -passin 'pass:admin1jboss!' \
    -passout 'pass:admin1jboss!' \
    -in ca/intermediate/certs/client.cert.pem \
    -inkey ca/intermediate/private/client.key.pem \
    -CAfile ca/intermediate/certs/ca-chain.cert.pem \
    -name client \
    -out client.p12

# import intermediate ca

keytool -importcert \
    -J-Djava.security.properties="$HOME"/java.security.properties \
    -keystore NONE \
    -alias intermediate_ca \
    -file ca/intermediate/certs/deploy-ca-chain.cert.pem \
    -deststorepass 'admin1jboss!' \
    -storetype PKCS11

# import server cert and key

keytool -importkeystore \
    -J-Djava.security.properties="$HOME"/java.security.properties \
    -srckeystore server.p12 \
    -destkeystore NONE \
    -srcstoretype PKCS12 \
    -deststoretype PKCS11 \
    -srcstorepass 'admin1jboss!' \
    -deststorepass 'admin1jboss!' \
    -srcalias appserver \
    -destalias appserver \
    -srckeypass 'admin1jboss!' \
    -destkeypass 'admin1jboss!' \

echo
echo "The following files are needed by JBoss EAP 7.1:"
echo
echo "    $HOME/fipsdb"
echo "    $HOME/java.security.properties"
echo "    $HOME/nss-pkcs11-fips.cfg"
echo
echo "The client cert and key are available in pkcs12 format here:"
echo
echo "    $HOME/client.p12"
echo
echo "The root CA certificate is available in pem format here:"
echo "    $HOME/ca/certs/ca.cert.pem"
echo
