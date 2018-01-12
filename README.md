# Generate Test Certificates
The scripts follow these
[instructions](https://jamielinux.com/docs/openssl-certificate-authority/index.html).

## Install RHEL 7.4 in FIPS mode
When RHEL 7.4 first offers the installation menu, select the option
"Install Red Hat Enterprise Linux 7.4" from the main menu, press
TAB and then add `fips=1` to the vmlinuz line shown.  Make sure
that there is sufficient entropy during installation by typing on
the keyboard and moving the mouse around.  That single change to
the vmlinuz line will configure the operating system to be in FIPS
enforcing mode.

## Generate the certificates
After installing RHEL 7.4, copy the contents of this directory to
/root.  Edit the `demo.conf` script to use correct values for your
IP address and RHSM credentials and pool id.  Finally, run the
following commands as root:

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

* /root/server.p12 - the appserver certificate and private key
* /root/intermediate.cert.pem - the intermediate CA that signed the client and server certs
* /root/ca.cert.pem - the trusted root CA
    
The client browser should import the following files:

* /root/client.p12 - the client certificate and private key
* /root/ca.cert.pem - the trusted root CA

The default password used throughout is `admin1jboss!`

