# Generate Test Certificates
The scripts follow these
[instructions](https://jamielinux.com/docs/openssl-certificate-authority/index.html).

## Install RHEL 7.4 in FIPS mode
First, install RHEL 7.4. When selecting the option "Install Red Hat
Enterprise Linux 7.4" from the main menu, press TAB and then add
`fips=1` to the vmlinuz line shown.  Make sure that there is
sufficient entropy during installation by typing on the keyboard
and moving the mouse around.  That one change will configure the
operating system to be in FIPS enforcing mode.

## Generate the certificates
After installing RHEL 7.4, copy the contents of this directory to
/root.  Edit the `01-subscribe.sh` script to use correct values for
the RHSM `USERNAME`, RHSM `PASSWD`, and RHSM pool id as `SM_POOL_ID`.
Edit the `04-create-server-pair.sh` script to use the matching
`IP_ADDR` for the server.  Finally, run the following commands as
root:

    cd /root
    ./01-subscribe.sh

After the system reboots, run the remaining commands:

    cd /root
    ./02-create-root-pair.sh
    ./03-create-intermediate-pair.sh
    ./04-create-server-pair.sh
    ./05-create-client-pair.sh
    ./06-export-certs.sh

At the server, you'll need to import the following files into the
appropriate keystore:

* /root/ca.cert.pem - the root CA certificate with alias `root_ca`
* /root/ca-chain.cert.pem - the intermediate CA certificate with alias `intermediate_ca`
* /root/server.p12 - the application server certificate and private key with alias `appserver`
    
The client browser should import the following files:

* /root/ca.cert.pem - the root CA certificate with alias `root_ca`
* /root/client.p12 - the client certificate and private key

The default password used throughout is `admin1jboss!`

