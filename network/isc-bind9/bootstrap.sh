#!/usr/bin/env bash

function PassAuth {
    # enable VM password authentication
    # echo "PasswordAuthentication yes" > /etc/ssh/sshd_config.d/pass.conf
    # or use:
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    systemctl restart sshd.service
}

case $HOSTNAME in

Server-1)
    # enable ssh password
    PassAuth

    # install dnsmasq
    apt-get update && apt-get install dnsmasq -y
    systemctl disable systemd-resolved
    systemctl stop systemd-resolved

    # configure dnsmasq
    cp /vagrant/dhcp-dns.conf /etc/dnsmasq.d/dhcp-dns.conf
    cp /vagrant/hosts /etc/hosts

    # start dnsmasq
    service dnsmasq restart

    # enable routing and NAT
    sysctl -w net.ipv4.ip_forward=1
    iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
    # iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
    # iptables -A FORWARD -i enp0s3 -o enp0s8 -m state --state RELATED,ESTABLISHED -j ACCEPT

    # set route to Client-1 'lo' interface
    ip route add 172.17.15.0/24 via 10.81.5.254 dev enp0s8
    ;;

Client-1)
    # enable ssh password
    PassAuth

    # set 'lo' interface additional addresses
    ip addr add 172.17.15.1/24 dev lo
    ip addr add 172.17.25.1/24 dev lo

    # set routing to Client-2 network
    # need it because Vagrant uses additional NAT interface to communicate with VM
    ip route add 10.8.81.0/24 via 10.81.5.1 dev enp0s8
    ;;
Client-2)
    # enable ssh password
    PassAuth

    # set routing to Client-1 .25 network
    ip route add 172.17.25.0/24 via 172.16.5.1 dev eth2

    # set routing to Client-1 .15 network
    # need it because Vagrant uses additional NAT interface to communicate with VM
    ip route add 172.17.15.0/24 via 10.8.81.1 dev eth1
    ;;
esac
