#!/bin/bash

# The file to be edited, must contain "add_header Public-Key-Pins"                                                           
NGINX_SSL_CONFIG="/etc/nginx/inc.d/ssl.inc"                         

CERTS=(
        "https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.pem"
        "https://letsencrypt.org/certs/lets-encrypt-x2-cross-signed.pem"
        "https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem"
        "https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.pem"
)

getHash() {
        local TMPFILE="$(mktemp)"
        curl -s "$1" \
                | openssl x509 -noout -pubkey 2>/dev/null \
                | openssl asn1parse -inform pem -noout -out "${TMPFILE}" 2>/dev/null 
        openssl dgst -sha256 -binary "${TMPFILE}" | base64 2>/dev/null
}

for i in "${CERTS[@]}"; do
        HASHES+=( "$( getHash "$i" )" ) 
done 

HPKP_INJECT="$( printf 'pin-sha256="%s"; \n' "${HASHES[@]}" | sort -u | tr -d '\n' )" 

# Since enabling this is sort of a permanent thing, it's required first that
# NGINX_SSL_CONFIG contains "add_header Public-Key-Pins"
sed -ri "/Public-Key-Pins/s|(add_header Public-Key-Pins).*|\1 '${HPKP_INJECT}max-age=2592000; includeSubDomains';|" "${NGINX_SSL_CONFIG}"
