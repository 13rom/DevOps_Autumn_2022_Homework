#!/usr/bin/env bash

function PassAuth {
    # enable VM password authentication 
    echo "PasswordAuthentication yes" > /etc/ssh/sshd_config.d/pass.conf
    # or use:
    #sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config    
    systemctl restart sshd.service
}

case $HOSTNAME in

    vm1)
        # enable ssh password
        PassAuth

        # install dhcp server
        apt-get update && apt-get install isc-dhcp-server -y

        # install bind9 server
        apt-get install bind9 -y

        # configure dhcp server
        sed -i 's/INTERFACESv4=""/INTERFACESv4="enp0s8"/g' /etc/default/isc-dhcp-server
        cp /vagrant/dhcpd.conf /etc/dhcp/dhcpd.conf

        # configure dns server
        cp /vagrant/named.conf.local /etc/bind/named.conf.local
        cp /vagrant/named.conf.options /etc/bind/named.conf.options
        cp /vagrant/db.localnet /etc/bind/db.localnet

        # start dhcp and dns server
        service isc-dhcp-server restart
        service bind9 restart
    ;;

    vm2 | vm3)
        # enable ssh password
        PassAuth
    ;;
esac
