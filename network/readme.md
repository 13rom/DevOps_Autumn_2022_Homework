## Linux Networking Task

![Network diagram](screenshots/diagram-dhcp.png)

### Network build-up

1.&nbsp;Use already created internal-network for three VMs (**VM1**-**VM3**). **VM1** has NAT and internal, **VM2**, **VM3** – internal only interfaces.

Next [`Vagrantfile`](dnsmasq/Vagrantfile) is used as a base network setup for the lab (only `bootstrap.sh` will differ):

```ruby
VAGRANTFILE_API_VERSION = "2"
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 
  config.vm.define "VM1" do |vm1|
    vm1.vm.box = "ubuntu/focal64"
    vm1.vm.provider :virtualbox do |vb|
      vb.name = "VM1-net-gateway"
    end
    vm1.vm.hostname = "vm1"

    vm1.vm.network "private_network", ip: "192.168.12.10",
      virtualbox__intnet: "isolated"

    vm1.vm.provision :shell, path: "bootstrap.sh"

    vm1.vm.provision "shell", run: "always", inline: "systemd-resolve --interface enp0s8 --set-dns 192.168.12.10 --set-domain localnet"
    vm1.vm.provision "shell", run: "always", inline: <<-SHELL
      # enable routing
      sysctl -w net.ipv4.ip_forward=1
      iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
    SHELL
  end
 

  config.vm.define "VM2" do |vm2|
    vm2.vm.box = "ubuntu/focal64"
    vm2.vm.provider :virtualbox do |vb|
      vb.name = "VM2-net-gateway"
    end
    vm2.vm.hostname = "vm2"

    vm2.vm.network "private_network", type: "dhcp", mac: "080027fae675",
      virtualbox__intnet: "isolated"
    
    vm2.vm.provision :shell, path: "bootstrap.sh"
  end


  config.vm.define "VM3" do |vm3|
    vm3.vm.box = "ubuntu/focal64"
    vm3.vm.provider :virtualbox do |vb|
      vb.name = "VM3-net-gateway"
    end
    vm3.vm.hostname = "vm3"

    vm3.vm.network "private_network", type: "dhcp", mac: "08002752b7e0",
      virtualbox__intnet: "isolated"

    vm3.vm.provision :shell, path: "bootstrap.sh"
  end

end
```


### DNSMASQ DHCP + DNSMASQ DNS server

2.&nbsp;Install and configure DHCP server on **VM1**. (using DNSMASQ).

4.&nbsp;Using existed network for three VMs (from p.1) install and configure DNS server on **VM1**. (You can use DNSMASQ).


Next [`bootstrap.sh`](dnsmasq/bootstrap.sh) installs `dnsmasq` and configures it:

```bash
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

        # install dnsmasq
        apt-get update && apt-get install dnsmasq -y
        systemctl disable systemd-resolved
        systemctl stop systemd-resolved

        # configure dnsmasq
        cp /vagrant/dhcp-dns.conf /etc/dnsmasq.d/dhcp-dns.conf
        cp /vagrant/hosts /etc/hosts

        # start dnsmasq
        service dnsmasq restart
    ;;

    vm2 | vm3)
        # enable ssh password
        PassAuth
    ;;
esac
```

Server configuration:
```console
vagrant@vm1:~$ cat /etc/dnsmasq.d/dhcp-dns.conf | grep -Ev '^$|^#'
bogus-priv
no-resolv
server=/localnet/127.0.0.1
server=8.8.8.8
server=8.8.4.4
local=/localnet/
interface=enp0s8
expand-hosts
domain=localnet
dhcp-range=192.168.12.10,192.168.12.50,12h
dhcp-host=vm2
dhcp-host=vm3
dhcp-option=option:ntp-server,192.168.12.10
dhcp-leasefile=/var/lib/misc/dnsmasq.leases
log-dhcp
```
```console
vagrant@vm1:~$ cat /etc/hosts
127.0.0.1	localhost
192.168.12.10	vm1
192.168.12.20	vm2
192.168.12.30	vm3
```


### ISC DHCP + BIND9 DNS server

2.&nbsp;Install and configure DHCP server on **VM1**. (using ISC-DHSPSERVER).

4.&nbsp;Using existed network for three VMs (from p.1) install and configure DNS server on **VM1**. (You can use BIND9).


Next [`bootstrap.sh`](isc-bind9/bootstrap.sh) installs and configures `isc-dhcp-server` and `bind9`:

```bash
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
```

DHCP server configuration:

```console
vagrant@vm1:~$ cat /etc/dhcp/dhcpd.conf 
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
log-facility local7;

option domain-name "localnet";
option domain-name-servers 192.168.12.10;
option routers 192.168.12.10;

subnet 192.168.12.0 netmask 255.255.255.0 {
  range 192.168.12.40 192.168.12.50;
}

host vm2 {
  hardware ethernet 08:00:27:fa:e6:75;
  fixed-address 192.168.12.20;
  option host-name "vm2";
}

host vm3 {
  hardware ethernet 08:00:27:52:b7:e0;
  fixed-address 192.168.12.30;
  option host-name "vm3";
}
```

DNS server configuration:

```console
vagrant@vm1:~$ cat /etc/bind/named.conf.local 
zone "localnet" {
    type master;
    file "/etc/bind/db.localnet";
};
```
```console
vagrant@vm1:~$ cat /etc/bind/named.conf.options 
acl "localnet" {
        192.168.12.0/24;
        localhost;
};

options {
        directory "/var/cache/bind";

        listen-on { "localnet"; };

        forwarders {
                8.8.8.8;
                8.8.4.4;
        };

        recursion yes;
        allow-recursion { "localnet"; };
        allow-query { "localnet"; };

        dnssec-validation auto;
        auth-nxdomain no;

        listen-on-v6 { none; };
        version "NOT CURRENTLY AVAILABLE";
        querylog yes;
};
```
```console
vagrant@vm1:~$ cat /etc/bind/db.localnet 
;
; BIND data file for localnet
;
$TTL	604800
@	IN	SOA	vm1.localnet. root.vm1.localnet. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	vm1.localnet.
@	IN	A	127.0.0.1
@	IN	AAAA	::1
vm1	IN	A	192.168.12.10
vm2	IN	A	192.168.12.20
vm3	IN	A	192.168.12.30
```

### Server checks

3.&nbsp;Check **VM2** and **VM3** for obtaining network addresses from DHCP server.

```console
$ vagrant ssh -c "ip addr show enp0s8 | grep 'inet '" VM2
    inet 192.168.12.20/24 brd 192.168.12.255 scope global dynamic enp0s8
Connection to 127.0.0.1 closed.

$ vagrant ssh -c "ip addr show enp0s8 | grep 'inet '" VM3
    inet 192.168.12.30/24 brd 192.168.12.255 scope global dynamic enp0s8
Connection to 127.0.0.1 closed.
```

5.&nbsp;Check **VM2** and **VM3** for gaining access to DNS server (naming services).

```console
$ vagrant ssh -c "ping -c 3 vm1" VM2
PING vm1.localnet (192.168.12.10) 56(84) bytes of data.
64 bytes from vm1.localnet (192.168.12.10): icmp_seq=1 ttl=64 time=0.236 ms
64 bytes from vm1.localnet (192.168.12.10): icmp_seq=2 ttl=64 time=1.11 ms
64 bytes from vm1.localnet (192.168.12.10): icmp_seq=3 ttl=64 time=1.22 ms

--- vm1.localnet ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2109ms
rtt min/avg/max/mdev = 0.236/0.852/1.216/0.438 ms
Connection to 127.0.0.1 closed.

$ vagrant ssh -c "resolvectl query epam.com" VM3
epam.com: 3.214.134.159                        -- link: enp0s8

-- Information acquired via protocol DNS in 62.0ms.
-- Data is authenticated: no
Connection to 127.0.0.1 closed.
```

### OSPF

6.&nbsp;Using the scheme which follows, configure dynamic routing using OSPF protocol.

This part of the lab is done using [`Vagrantfile`](ospf/Vagrantfile):

```ruby
VAGRANTFILE_API_VERSION = "2"
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 
  config.vm.define "VM1" do |vm1|
    vm1.vm.box = "ubuntu/focal64"
    vm1.vm.provider :virtualbox do |vb|
      vb.name = "VM1-net-gateway"
    end
    vm1.vm.hostname = "vm1"

    vm1.vm.network "private_network", ip: "192.168.12.10", virtualbox__intnet: "isolated"

    vm1.vm.provision :shell, path: "bootstrap.sh"

    vm1.vm.provision "shell", run: "always", inline: <<-SHELL
      # enable routing
      sysctl -w net.ipv4.ip_forward=1
      iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
    SHELL
  end
 

  config.vm.define "VM2" do |vm2|
    vm2.vm.box = "ubuntu/focal64"
    vm2.vm.provider :virtualbox do |vb|
      vb.name = "VM2-net-gateway"
    end
    vm2.vm.hostname = "vm2"

    vm2.vm.network "private_network", ip: "192.168.12.20", virtualbox__intnet: "isolated"
    
    vm2.vm.provision :shell, path: "bootstrap.sh"
  end


  config.vm.define "VM3" do |vm3|
    vm3.vm.box = "ubuntu/focal64"
    vm3.vm.provider :virtualbox do |vb|
      vb.name = "VM3-net-gateway"
    end
    vm3.vm.hostname = "vm3"

    vm3.vm.network "private_network", ip: "192.168.12.30", virtualbox__intnet: "isolated"

    vm3.vm.network "public_network", bridge: "wlp1s0"

    vm3.vm.provision :shell, path: "bootstrap.sh"
    vm3.vm.provision "shell", run: "always", inline: <<-SHELL
      # enable routing
      sysctl -w net.ipv4.ip_forward=1
      iptables -t nat -A POSTROUTING -o enp0s9 -j MASQUERADE
    SHELL
  end

end
```

VM Provisioning is done by [`bootstrap.sh`](ospf/bootstrap.sh):

```bash
#!/usr/bin/env bash

HOSTIP=$(hostname -I | awk '{ print $2 }')

function PassAuth {
    # enable VM password authentication 
    echo "PasswordAuthentication yes" > /etc/ssh/sshd_config.d/pass.conf
    # or use:
    #sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config    
    systemctl restart sshd.service
}

# enable ssh password
PassAuth

# install ospf router
apt-get update && apt-get install quagga -y

# configure router
cp /vagrant/daemons /etc/quagga/daemons
cp /vagrant/zebra.conf /etc/quagga/zebra.conf
cp /vagrant/ospfd.conf /etc/quagga/ospfd.conf

sed -i -e "s/vmname/$HOSTNAME/g" /etc/quagga/zebra.conf
sed -i -e "s/vmip/$HOSTIP/g" /etc/quagga/ospfd.conf

mkdir /var/log/quagga
# chown -R quagga:quagga /etc/quagga
# chown -R quagga:quagga /var/log/quagga

# start router
service zebra restart
service ospfd restart
```

[`zebra.conf`](ospf/zebra.conf):
```
!
hostname vmname
password zebra
enable password zebra
log file /var/log/quagga/zebra.log
!
interface enp0s8
!
interface lo
!
!
!
line vty
!
```

[`ospfd.conf`](ospf/ospfd.conf):
```
log file /var/log/quagga/ospdf.log
!
router ospf
    ospf router-id vmip
    log-adjacency-changes
    redistribute kernel
    redistribute connected
    redistribute static
    network 192.168.12.0/24 area 0
!
line vty
!
```

7.&nbsp;Check results.

```console
vagrant@vm1:~$ ip route
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100 
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 
10.0.2.2 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100 
192.168.1.0/24 via 192.168.12.30 dev enp0s8 proto zebra metric 20 
192.168.1.1 via 192.168.12.30 dev enp0s8 proto zebra metric 20 
192.168.12.0/24 dev enp0s8 proto kernel scope link src 192.168.12.10

vagrant@vm1:~$ tracepath -n 192.168.1.1
 1?: [LOCALHOST]                      pmtu 1500
 1:  192.168.12.30                                         1.251ms 
 1:  192.168.12.30                                         0.712ms 
 2:  192.168.1.1                                           3.561ms reached
     Resume: pmtu 1500 hops 2 back 2
```


```console
vagrant@vm3:/var/log$ telnet localhost 2601
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.

Hello, this is Quagga (version 1.2.4).
Copyright 1996-2005 Kunihiro Ishiguro, et al.


User Access Verification

Password: 
vm3> show ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, P - PIM, A - Babel, N - NHRP,
       > - selected route, * - FIB route

K * 0.0.0.0/0 via 192.168.1.1, enp0s9 inactive, src 192.168.1.124
O>* 10.0.2.0/24 [110/20] via 192.168.12.10, enp0s8, 00:39:56
  *                      via 192.168.12.20, enp0s8, 00:39:56
O>* 10.0.2.2/32 [110/20] via 192.168.12.10, enp0s8, 00:39:56
  *                      via 192.168.12.20, enp0s8, 00:39:56
K   10.0.2.2/32 is directly connected, enp0s3 inactive
C>* 127.0.0.0/8 is directly connected, lo
C>* 192.168.1.0/24 is directly connected, enp0s9
K>* 192.168.1.1/32 is directly connected, enp0s9
O   192.168.12.0/24 [110/10] is directly connected, enp0s8, 00:39:57
C>* 192.168.12.0/24 is directly connected, enp0s8
```