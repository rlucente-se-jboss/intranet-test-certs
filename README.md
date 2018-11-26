# Generate Test Certificates
The scripts follow these
[instructions](https://jamielinux.com/docs/openssl-certificate-authority/index.html).
The goal is to have a set of keys and certificates that match
real-world scenarios vs the common practice of self-signed certificates.

This works on RHEL as well as Mac OSX. Simply run them from the
directory where you cloned this repository.

## Install RHEL in FIPS mode (RHEL Only)
When RHEL first offers the installation menu, select the option
"Install Red Hat Enterprise Linux 7.4" from the main menu, press
TAB and then add `fips=1` to the vmlinuz line shown.  Make sure
that there is sufficient entropy during installation by typing on
the keyboard and moving the mouse around.  That single change to
the vmlinuz line will configure the operating system to be in FIPS
enforcing mode.

## Generate the certificates
Clone this repository.  Edit the `demo.conf` script to use correct
values for your IP address and, if using RHEL, RHSM credentials and
pool id.

On RHEL only, run the following command and then wait for the system
to reboot:

    sudo ./01-subscribe.sh

Generate the needed keys and certificates by running the commands:

    ./02-create-root-pair.sh
    ./03-create-intermediate-pair.sh
    ./04-create-server-pair.sh
    ./05-create-client-pair.sh
    ./06-export-certs.sh

At the server, you'll need to import the following files into the
appropriate keystore:

* server.p12 - the server's certificate and private key
* ca-chain.cert.pem - the intermediate CA (chained with the root CA) that signed the client and server certs
    
The client browser should import the following files:

* client.p12 - the client certificate and private key
* ca-chain.cert.pem - the intermediate CA (chained with the root CA) that signed the client and server certs

The default password can be overridden in `demo.conf`.

