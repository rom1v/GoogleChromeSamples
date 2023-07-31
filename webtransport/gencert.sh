#!/bin/bash

# Generate ECDSA
# https://stackoverflow.com/questions/75979276/do-i-have-to-get-a-valid-ssl-certificate-to-make-webtranport-server-examples-wor/76125650#76125650

openssl req -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -days 7 -keyout mycert.key -x509 -out mycert.pem -subj '/CN=Test Certificate' -addext 'subjectAltName = DNS:localhost'

openssl x509 -pubkey -noout -in mycert.pem |
  openssl ec -pubin -outform der |
  openssl dgst -sha256 -binary | base64

#openssl x509 -pubkey -noout -in mycert.pem |
#  openssl ec -pubin -outform der |
#  openssl dgst -sha256

SHA256=$(openssl x509 -pubkey -noout -in mycert.pem |
  openssl ec -pubin -outform der | sha256sum | head -c64)
echo SHA256=$SHA256

echo 'serverCertificateHashes: ['
echo '  {'
echo '    algorithm: "sha-256",'
echo '    value: new Uint8Array(['
echo $SHA256 | fold -w16 | sed 's/\(..\)/0x\1, /g;s/^/      /;s/\s*$//'
echo '    ]),'
echo '  },'
echo '],'
