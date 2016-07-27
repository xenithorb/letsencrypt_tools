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
                del*) cmd="-D" ;;
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

iptables_control add 

letsencrypt --agree-tos renew 

iptables_control del 

find "$LE_DIR" -mindepth 1 -maxdepth 1 -type d -print0| while read -rd '' domain; do
        domain="${domain##*/}" 
        make_all_cert "$domain"
done 

# Do generic reloading of services and/or 
# Source in another script here 

#
