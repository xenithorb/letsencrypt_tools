#!/bin/bash
#
# Cron to open port 80/443 for ACME protocol with
# Let's encrypt and renew system certificates.
#
# Author: Michael Goodwin
# Date: 2016-05-22
# OS: CentOS 7
#
# set -x

CHAIN="INPUT"
# The 2 below assumes that you want it to insert after
# rule number #2, check with `iptables -nvL --line-numbers`
INSERT_NUM=2
LE_DIR="/etc/letsencrypt/live"
#FORCE_RENEW="--force-renew"
FORCE_RENEW=''
SELF="$PWD/$0"

RULES=(
        "-p tcp -m conntrack --ctstate NEW -m tcp --dport 80 -j ACCEPT"
        "-p tcp -m conntrack --ctstate NEW -m tcp --dport 443 -j ACCEPT"
)

iptables_control() {
        local cmd
        local chain="$CHAIN"
        case "$@" in
                add*)
                        cmd="-I"
                        chain="${chain} ${INSERT_NUM}"
                ;;
                del*)
                        cmd="-D"
                ;;
        esac
        for i in "${!RULES[@]}"; do
                iptables $cmd $chain ${RULES[i]}
        done
}

make_all_cert() {
        local domain="$1"
        local le_dom_loc="${LE_DIR}/${domain}"
        cat "${le_dom_loc}/"{fullchain,privkey}.pem > "${le_dom_loc}/all.pem"
}

pre_hook() {
        iptables_control add
}

renew_hook() {
        while read -rd '' domain; do
                domain="${domain##*/}"
                make_all_cert "$domain"
        done < <(
                find "$LE_DIR" -mindepth 1 -maxdepth 1 -type d -print0
        )

        # Do generic reloading of services and/or
        # Call in another script here

}

post_hook() {
        iptables_control del
}

if [[ $1 == '' ]]; then
        letsencrypt --agree-tos $FORCE_RENEW renew \
                --post-hook "$SELF post_hook" \
                --pre-hook "$SELF pre_hook" \
                --renew-hook "$SELF renew_hook"
else
        eval "$@"
fi
