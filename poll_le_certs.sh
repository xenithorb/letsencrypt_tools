#!/bin/bash

POLL_INTERVAL="300" # in seconds

# A list (array) of files to poll
CERTFILES=(
        "/etc/letsencrypt/live/mgoodwin.net/cert.pem"
)

# Services that need to be restarted to consume the updated cert
SERVICES=(
        "cyrus-imapd.service"
        "nginx.service"
        #"guam.service"
        "postfix.service"
)

restart_services() {
        systemctl restart "${@}"
}

get_mtime() {
        stat -c '%Y' "$1"
}

entrapment() {
	kill $(jobs -rp)
}
trap entrapment INT TERM

# Check to see if the mount is NFS, if so, then poll the file
# If not, remove the file from the array because it's not mounted yet
for i in "${!CERTFILES[@]}"; do
        if ! ( df -T "${CERTFILES[i]}" | awk '$2~"nfs"{a=1}END{exit !a}' ); then
                unset CERTFILES[$i]
        fi
done


for i in "${!CERTFILES[@]}"; do
        (
	old_ts=""
	prerun=""
        while :; do
                new_ts="$( get_mtime "${CERTFILES[i]}" )"
                if [[ "$new_ts" != "$old_ts" && "$prerun" ]]; then
                        restart_services "${SERVICES[@]}"
                fi
                prerun=1
                old_ts="$new_ts"
                sleep "$POLL_INTERVAL"
        done
        ) &
done

wait
