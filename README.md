Make sure that the bc-fips-1.0.1.jar from [Legion of the Bouncy Castle](https://bouncycastle.org/fips-java)
is in this directory.  The scripts follow these
[instructions](https://jamielinux.com/docs/openssl-certificate-authority/index.html).

After installing RHEL 7.4, copy the contents of this directory to
/root.  Edit the `01-subscribe.sh` script to use correct values for
the RHSM `USERNAME` and `PASSWD`.  You can also set the RHSM pool
id via `SM_POOL_ID`.  Edit the `04-create-server-pair.sh` and
`06-create-server-keystores.sh` scripts to use the matching `IP_ADDR`
for the server.  Finally, run the following commands as root:

    cd /root
    ./01-subscribe.sh
    ./02-create-root-pair.sh
    ./03-create-intermediate-pair.sh
    ./04-create-server-pair.sh
    ./05-create-client-pair.sh
    ./06-create-server-keystores.sh

The server keystore, `keystore.bcfks`, contains
 
* the intermediate CA certificate with alias `intermediate_ca`
* the application server cert and private key with alias `appserver`
    
The server truststore, `truststore.bcfks`, contains

* the root CA with alias `root_ca`

The client browser should import

* The root CA available at /root/ca/certs/ca.cert.pem as an authority
* The client's certificate and private key available at /root/client.p12

