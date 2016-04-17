set -x                                                                                                             
                                                                                                                   
NGINX_SSL_CONFIG="/etc/nginx/inc.d/ssl.inc"                                                                        
OTHER_CERTS=(
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
        HASH="$( openssl dgst -sha256 -binary "${TMPFILE}" | base64 2>/dev/null )"
        echo "$HASH" 
}

for i in "${OTHER_CERTS[@]}"; do
        HASHES+=( "$( getHash "$i" )" ) 
done 

HPKP_INJECT="$( printf 'pin-sha256="%s"; \n' "${HASHES[@]}" | sort -u | tr -d '\n' )" 

sed -ri "/Public-Key-Pins/s|(add_header Public-Key-Pins).*|\1 '${HPKP_INJECT}max-age=2592000; includeSubDomains';|" "${NGINX_SSL_CONFIG}"
