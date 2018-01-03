#!/bin/bash

IP_ADDR='PUT SERVER IP ADDRESS HERE'

# import root ca to truststore

keytool -importcert \
    -trustcacerts \
    -noprompt \
    -alias root_ca \
    -file ca/certs/ca.cert.pem \
    -destkeystore truststore.bcfks \
    -deststorepass secretpassword \
    -storetype BCFKS \
    -providername BCFIPS \
    -providerclass org.bouncycastle.jcajce.provider.BouncyCastleFipsProvider

# export server cert

openssl pkcs12 -export \
    -passin pass:secretpassword \
    -passout pass:secretpassword \
    -in ca/intermediate/certs/appserver.$IP_ADDR.nip.io.cert.pem \
    -inkey ca/intermediate/private/appserver.$IP_ADDR.nip.io.key.pem \
    -CAfile ca/intermediate/certs/ca-chain.cert.pem \
    -name appserver \
    -out server.p12

# export client cert

openssl pkcs12 -export \
    -passin pass:secretpassword \
    -passout pass:secretpassword \
    -in ca/intermediate/certs/client.cert.pem \
    -inkey ca/intermediate/private/client.key.pem \
    -CAfile ca/intermediate/certs/ca-chain.cert.pem \
    -name client \
    -out client.p12

# import intermediate ca

keytool -importcert \
    -noprompt \
    -alias intermediate_ca \
    -file ca/intermediate/certs/deploy-ca-chain.cert.pem \
    -destkeystore keystore.bcfks \
    -deststorepass secretpassword \
    -storetype BCFKS \
    -providername BCFIPS \
    -providerclass org.bouncycastle.jcajce.provider.BouncyCastleFipsProvider

# import server cert and key

keytool -importkeystore \
    -srckeystore server.p12 \
    -destkeystore keystore.bcfks \
    -srcstoretype PKCS12 \
    -deststoretype BCFKS \
    -srcstorepass secretpassword \
    -deststorepass secretpassword \
    -srcalias appserver \
    -destalias appserver \
    -srckeypass secretpassword \
    -destkeypass secretpassword \
    -providername BCFIPS \
    -providerclass org.bouncycastle.jcajce.provider.BouncyCastleFipsProvider

echo
echo "The following files are needed by JBoss EAP 7.1:"
echo
echo "    keystore.bcfks"
echo "    truststore.bcfks"
echo
echo "The client cert and key are available in pkcs12 format here:"
echo
echo "    client.p12"
echo
