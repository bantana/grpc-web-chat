#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Change the specific details here. Pay close attention to the CA_CN_NAME and the CN_NAME.          #
# Also not that the backslashes (\\) after -subj should probably be replaced for Mac/Unix systems.  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

C_CODE=ZA
STATE=WesternCape
LOCALITY=Stellenbosch
COMPANY=ExampleCo
UNIT=ExampleCoSecurityDepartment
CA_CN_NAME=example-ca.com
CN_NAME=ExampleCoCN
EMAIL=security@example.com
PASS=1234

# Create directories for certificates
echo Attempting to create directories for certificates...
mkdir envoy/certificates
mkdir client/certificates

# Certificate Authority
echo Generating CA key...
 openssl genrsa -des3 -passout pass:${PASS} -out envoy/certificates/ca.key 2048

echo Generating CA cetificate...
openssl req -new -x509 -passin pass:${PASS} -days 365 -key envoy/certificates/ca.key -out envoy/certificates/ca.crt -subj "//C=${C_CODE}\ST=${STATE}\L=${LOCALITY}\O=${COMPANY}\OU=${UNIT}\CN=${CA_CN_NAME}"

# Server side key
echo Generate server key...
openssl genrsa -des3 -passout pass:${PASS} -out envoy/certificates/server.key 2048

echo Generating server signing request...
openssl req -new -passin pass:${PASS} -key envoy/certificates/server.key -out envoy/certificates/server.csr -subj "//C=${C_CODE}\ST=${STATE}\L=${LOCALITY}\O=${COMPANY}\OU=${UNIT}\CN=${CN_NAME}"

echo Generating server certificate...
openssl x509 -req -passin pass:${PASS} -days 365 -in envoy/certificates/server.csr -CA envoy/certificates/ca.crt -CAkey envoy/certificates/ca.key -set_serial 01 -out envoy/certificates/server.crt -sha256 -extfile envoy/v3.ext

# Remove servery key passphrase
echo Removing passphrase from server key...
openssl rsa -passin pass:${PASS} -in envoy/certificates/server.key -out envoy/certificates/server.key

# Copy certificates to client file server
echo Copying server key and server certificate to client file server...
cp -rf envoy/certificates/server.key client/certificates/server.key
cp -rf envoy/certificates/server.crt client/certificates/server.crt
