#!/bin/bash
#
# Cron to open port 80/443 for ACME protocol with 
# Let's encrypt and renew system certificates.
# 
# Author: Michael Goodwin
# Date: 2016-05-22
# OS: CentOS 7
#
#set -x

CHAIN="INPUT"
# The 2 below assumes that you want it to insert after
# rule number #2, check with `iptables -nvL --line-numbers`
INSERT_NUM=2
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

iptables_control add 

letsencrypt --agree-tos renew 

iptables_control del 


# Do generic reloading of services and/or 
# Source in another script here 

#