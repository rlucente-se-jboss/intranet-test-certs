#!/bin/bash

. $(dirname $0)/demo.conf

tmpfile=$(mktemp /tmp/security.providers.list.XXXXXX)

PUSHD "$WORK_DIR"

JRE_HOME=$(java -XshowSettings:properties -version 2>&1 | grep java.home | \
    awk '{print $3}')

cat > java.security.properties <<END1
#
# This file overrides the values in the java.security policy file
# which can be found at:
#
#    JRE_HOME=$JRE_HOME
#    \$JRE_HOME/lib/security/java.security
#
END1

JAVA_SECURITY_POLICY="$JRE_HOME/lib/security/java.security"
grep -E '^security.provider.[0-9]+=' $JAVA_SECURITY_POLICY > "$tmpfile"

LAST_PROVIDER_NUM=$(tail -1 "$tmpfile" | cut -d. -f3 | cut -d= -f1)
for ((i="$LAST_PROVIDER_NUM";i>0;i--));
do
    (( newnum = i + 1 ))
    sed -i.bak "s/\.$i=/.$newnum=/g" "$tmpfile"
done
sed -i.bak "s/\(com\.sun\.net\.ssl\.internal\.ssl\.Provider\)$/\1 SunPKCS11-fips/g" "$tmpfile"

echo "security.provider.1=sun.security.pkcs11.SunPKCS11 \${user.home}/nss-pkcs11-fips.cfg" >> java.security.properties
cat "$tmpfile" >> java.security.properties

cat >> java.security.properties <<END2

# make entropy pool non-blocking
securerandom.source=file:/dev/urandom

END2

cat > "$WORK_DIR"/nss-pkcs11-fips.cfg <<END3
name = SunPKCS11-fips
nssLibraryDirectory = /usr/lib64
nssSecmodDirectory = $HOME/fipsdb
nssDbMode = readWrite
nssModule = fips
END3

POPD

rm -f "$tmpfile" "$tmpfile.bak"

