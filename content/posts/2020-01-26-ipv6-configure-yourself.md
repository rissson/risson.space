---
title: IPv6, configure yourself
tags:
  - IPv6
  - DHCP
categories:
  - EPITA
  - Sysadmin
  - Networking
series:
  - EPITA projects
date: 2020-01-26T23:58:00+0100
lastmod: 2020-05-24T01:52:00+0200
---

> #### Note to the reader
>
> This post was written for a school projet, and thus in a hurry. It cleary
> needs some editing and reviewing as it probably contains inaccurate
> information. You shouldn't use this as a reference. You've been warned.
>
> As I continue my journey on learning IPv6, I'll probably come back here and
> correct and complete it.

Here is a deep dive into how a device configures its IPv6 addresses (Link Local
and Global Unicat addresses specifically) when you plug it into a network.

## Rollback: how it works in IPv4

Let's refresh our memory on how DHCPv4 works!

When a host, that has only been configured to get an IP from a DHCP server, is
plugged into an IPv4 network, it sends out a `DHCP discover` message, that
looks like this:

```
Ethernet II, Src: LcfcHefe_ff:d4:78 (54:e1:ad:ff:d4:78), Dst: Broadcast (ff:ff:ff:ff:ff:ff)
Internet Protocol Version 4, Src: 0.0.0.0, Dst: 255.255.255.255
User Datagram Protocol, Src Port: 68, Dst Port: 67
Dynamic Host Configuration Protocol (Discover)
    Message type: Boot Request (1)
    Hardware type: Ethernet (0x01)
    Hardware address length: 6
    Hops: 0
    Transaction ID: 0xff08862c
    Seconds elapsed: 5
    Bootp flags: 0x0000 (Unicast)
    Client IP address: 0.0.0.0
    Your (client) IP address: 0.0.0.0
    Next server IP address: 0.0.0.0
    Relay agent IP address: 0.0.0.0
    Client MAC address: LcfcHefe_ff:d4:78 (54:e1:ad:ff:d4:78)
    Client hardware address padding: 00000000000000000000
    Server host name not given
    Boot file name not given
    Magic cookie: DHCP
    Option: (53) DHCP Message Type (Discover)
    Option: (50) Requested IP Address (192.168.1.27)
    Option: (12) Host Name
    Option: (55) Parameter Request List
    Option: (255) End
    Padding: 000000000000000000000000000000000000000000000000…
```

The `DHCP Discover` requests is a Layer 2 broadcast message (the destination
MAC address is `ff:ff:ff:ff:ff:ff`) asking everyone on the same Layer 2
broadcast domain (basically everyone on the same VLAN, or the same switch) if
they are a DHCP server.

If a DHCP server is present, it should respond with a `DHCP Offer`:

```
Ethernet II, Src: CheapboxS_31:ba:e4 (70:fc:8f:31:ba:e4), Dst: LcfcHefe_ff:d4:78 (54:e1:ad:ff:d4:78)
Internet Protocol Version 4, Src: 192.168.1.254, Dst: 192.168.1.27
User Datagram Protocol, Src Port: 67, Dst Port: 68
Dynamic Host Configuration Protocol (Offer)
    Message type: Boot Reply (2)
    Hardware type: Ethernet (0x01)
    Hardware address length: 6
    Hops: 0
    Transaction ID: 0xff08862c
    Seconds elapsed: 0
    Bootp flags: 0x0000 (Unicast)
    Client IP address: 0.0.0.0
    Your (client) IP address: 192.168.1.27
    Next server IP address: 0.0.0.0
    Relay agent IP address: 0.0.0.0
    Client MAC address: LcfcHefe_ff:d4:78 (54:e1:ad:ff:d4:78)
    Client hardware address padding: 00000000000000000000
    Server host name not given
    Boot file name not given
    Magic cookie: DHCP
    Option: (53) DHCP Message Type (Offer)
    Option: (54) DHCP Server Identifier (192.168.1.254)
    Option: (51) IP Address Lease Time: (43200)s 12 hours
    Option: (1) Subnet Mask (255.255.255.0)
    Option: (3) Router: 192.168.1.254
    Option: (6) Domain Name Server
    Option: (28) Broadcast Address (192.168.1.255)
    Option: (255) End
    Padding: 000000000000000000000000000000000000000000000000…
```

This is basically the DHCP telling the host `Hey, here is an IPv4 if you want
it. It's 192.168.1.27/24, the gateway should be 192.168.1.254, have fun and ask
me for a new IP in 12 hours`.

If the host is still present, it will send a `DHCP Request`, that asks the DHCP
server to use that IP:

```
Ethernet II, Src: LcfcHefe_ff:d4:78 (54:e1:ad:ff:d4:78), Dst: Broadcast (ff:ff:ff:ff:ff:ff)
Internet Protocol Version 4, Src: 0.0.0.0, Dst: 255.255.255.255
User Datagram Protocol, Src Port: 68, Dst Port: 67
Dynamic Host Configuration Protocol (Request)
    Message type: Boot Request (1)
    Hardware type: Ethernet (0x01)
    Hardware address length: 6
    Hops: 0
    Transaction ID: 0xff08862c
    Seconds elapsed: 5
    Bootp flags: 0x0000 (Unicast)
    Client IP address: 0.0.0.0
    Your (client) IP address: 0.0.0.0
    Next server IP address: 0.0.0.0
    Relay agent IP address: 0.0.0.0
    Client MAC address: LcfcHefe_ff:d4:78 (54:e1:ad:ff:d4:78)
    Client hardware address padding: 00000000000000000000
    Server host name not given
    Boot file name not given
    Magic cookie: DHCP
    Option: (53) DHCP Message Type (Request)
    Option: (54) DHCP Server Identifier (192.168.1.254)
    Option: (50) Requested IP Address (192.168.1.27)
    Option: (12) Host Name: my_wonderful_computer
    Option: (55) Parameter Request List
    Option: (255) End
    Padding: 00000000000000000000000000000000000000
```

It says `Hey, I'm my_wonderful_computer and I'd like the IP 192.168.1.27, and
also some other stuff such as the gateway, the subnet, the domain name and the
DNS server` (and more but this is just a reminder of all the information that
goes through DHCP).

And if all goes well, the DHCP server answers with a `DHCP ACK`:

```
Ethernet II, Src: CheapboxS_31:ba:e4 (70:fc:8f:31:ba:e4), Dst: LcfcHefe_ff:d4:78 (54:e1:ad:ff:d4:78)
Internet Protocol Version 4, Src: 192.168.1.254, Dst: 192.168.1.27
User Datagram Protocol, Src Port: 67, Dst Port: 68
Dynamic Host Configuration Protocol (ACK)
    Message type: Boot Reply (2)
    Hardware type: Ethernet (0x01)
    Hardware address length: 6
    Hops: 0
    Transaction ID: 0xff08862c
    Seconds elapsed: 0
    Bootp flags: 0x0000 (Unicast)
    Client IP address: 0.0.0.0
    Your (client) IP address: 192.168.1.27
    Next server IP address: 0.0.0.0
    Relay agent IP address: 0.0.0.0
    Client MAC address: LcfcHefe_ff:d4:78 (54:e1:ad:ff:d4:78)
    Client hardware address padding: 00000000000000000000
    Server host name not given
    Boot file name not given
    Magic cookie: DHCP
    Option: (53) DHCP Message Type (ACK)
    Option: (54) DHCP Server Identifier (192.168.1.254)
    Option: (51) IP Address Lease Time: (43200s) 12 hours
    Option: (1) Subnet Mask (255.255.255.0)
    Option: (3) Router: 192.168.1.254
    Option: (6) Domain Name Server
        Domain Name Server: 1.1.1.1
        Domain Name Server: 1.0.0.1
        Domain Name Server: 208.67.222.222
        Domain Name Server: 208.67.220.220
    Option: (28) Broadcast Address (192.168.1.255)
    Option: (255) End
    Padding: 000000000000000000000000000000000000000000000000…
```

It says `Hey, here you go! Have a blast!` (and gives all the stuff it already
gave in the `DHCP Offer` plus the stuff the host request in its `DHCP
Request`).

All in all, from the moment I plugged the cable in my computer, it took a bit
more than seven seconds for my computer to have an IPv4, and I was able to make
my first request to an actual server.  During that time, IPv6 was also
configuring itself, and I was able to make a request to an actual server after
a bit less than 3 seconds[^1]. Let's see how that went.

[^1]: Benchmark absolutely realized in perfect conditions. Actually not, but
      just a quick observation on the fly.

## Back to it: auto-configuration in IPv6

Before we dive in, note that IPv6 also has a way to configure routes
automatically, using Neighbor Discovery, but this will not be discussed here.

Configuring an address automatically on a host that connects to a network for
the first time has one objective: acquire an address that is unique on the
network. To do that, a host goes through three steps: creating a Link Local
address, check its unicity and get a Global Unicast address. For this last step,
there are two ways to achieve this:

* Stateless Auto-configuration (SLAAC), usually used when there is no need to
  administrate what IPs are attributed to which hosts;
* Stateful auto-configuration (DHCPv6), usually used when there is a need to
  administrate what IPs are attributed to which hosts.

### Let's talk to other chaps in my network

#### Creating a link local address

What happens is you take the MAC address of the interface, you convert that to
an EUI-64[^2] and you put the Link Local prefix (`fe80::/64`) in front of that
and you're basically done!

[^2]: ["Guidelines for Use of Extended Unique Identifier (EUI), Organizationnaly
        Unique Identifier (OUI), and Company ID (CID)" (PDF). IEEE Standards
        Association. (Page
      15)](https://standards.ieee.org/content/dam/ieee-standards/standards/web/documents/tutorials/eui.pdf)

Example: from a MAC address `54:e1:ad:ff:d4:78`, you get the EUI-64
`56:e1:ad:ff:fe:ff:d4:78`. Let's integrate that into `fe80::/64` and we get
`fe80::56e1:adff:feff:d478/64` and we have a Link Local address! Let's verify
it's not already in use on the network we just plugged into.

#### Detecting a duplicate Link Local address

To check if a Link Local (actually it also works for Global Unicast) address is
already in use, the host uses the DAD (for those who have seen Lucifer I'm not
talking about God) algorithm. DAD stands for Duplicate Address Detection. It
uses Neighbor Solicitation and Neighbor Advertisement.

The host sends a Neighbor Solicitation message to see if some host already has
the Link Local address it is trying to configure:

```
Ethernet II, Src: LcfcHefe_ff:d4:78 (54:e1:ad:ff:d4:78), Dst: IPv6mcast_ff:03:63:26 (33:33:ff:03:63:26)
Internet Protocol Version 6, Src: ::, Dst: ff02::1:ff03:6326
Internet Control Message Protocol v6
    Type: Neighbor Solicitation (135)
    Code: 0
    Checksum: 0x4ef1 [correct]
    [Checksum Status: Good]
    Reserved: 00000000
    Target Address: fe80::56e1:adff:feff:d478
    ICMPv6 Option (Nonce)
        Type: Nonce (14)
        Length: 1 (8 bytes)
        Nonce: b97d2048e428
```

From there, three events can occur:

* A Neighbor Advertisement message is received from the target Link Local
  address: the address is already in use;
* A Neighbor Solicitation message is received from another host trying to
  configure the same Link Local address using the DAD algorithm: neither of
  those hosts can use that address;
* Nothing is received after 1 second (default value): the address is considered
  unique and goes from a provisional to a valid state and is assigned to the
  host's interface.

During the execution of the Duplicate Address Detection, the configured Link
Local address is considered provisional and is used only to receive Neighbor
Solicitation and Advertisement messages, all other messages are drop in order
not to interfere with an eventual host that has the Link Local address we are
trying to configure. If the address is already in use, human intervention is
required.

The DAD algorithm is not completely reliable, especially if you have a machine
with a statically assigned IP that is cut off from the network.

### Hello, World!

Now that we have a Link Local address, let's get ourselves a Global Unicast
address.

First, let's find a router. To do so, the host sends a Router Solicitation
message, which is a special type of Neighbor Solicitation:

```
Ethernet II, Src: LcfcHefe_ff:d4:78 (54:e1:ad:ff:d4:78), Dst: IPv6mcast_02 (33:33:00:00:00:02)
Internet Protocol Version 6, Src: fe80::1b53:b797:c803:6326, Dst: ff02::2
Internet Control Message Protocol v6
    Type: Router Solicitation (133)
    Code: 0
    Checksum: 0x7f22 [correct]
    [Checksum Status: Good]
    Reserved: 00000000
```

The router answers with a Router Advertisement message:

```
Ethernet II, Src: FreeboxS_31:ba:e4 (70:fc:8f:31:ba:e4), Dst: IPv6mcast_01 (33:33:00:00:00:01)
Internet Protocol Version 6, Src: fe80::72fc:8fff:fe31:bae4, Dst: ff02::1
Internet Control Message Protocol v6
    Type: Router Advertisement (134)
    Code: 0
    Checksum: 0xf840 [correct]
    [Checksum Status: Good]
    Cur hop limit: 64
    Flags: 0x00, Prf (Default Router Preference): Medium
        0... .... = Managed address configuration: Not set
        .0.. .... = Other configuration: Not set
        ..0. .... = Home Agent: Not set
        ...0 0... = Prf (Default Router Preference): Medium (0)
        .... .0.. = Proxy: Not set
        .... ..0. = Reserved: 0
    Router lifetime (s): 1800
    Reachable time (ms): 0
    Retrans timer (ms): 0
    ICMPv6 Option (Prefix information : 2a01:e34:ec15:5710::/64)
    ICMPv6 Option (Recursive DNS Server 2606:4700:4700::1111 2620:119:53::53)
    ICMPv6 Option (MTU : 1480)
    ICMPv6 Option (Source link-layer address : 70:fc:8f:31:ba:e4)
```

Note the destination address being `ff02::1` which is a multicast address
targeting all hosts on the network.

Also, note the flags `Managed address configuration` (`M`) and `Other
configuration` (`O`). The `M` flag indicates whether the address configuration
should be obtaineda using SLAAC (unset) or from a DHCPv6 server (set), and the
`O` flag indicates whether there is a configuration server for configurations
other than addresses.

#### Stateless Address Auto-configuration (SLAAC)

It works the same way as it did for the Link Local address, except we don't
use the Link Local prefix (`fe80::/64`), instead the host uses one given from
the router. To get this prefix, the host sends a Router Solicitation message,
which is a special type of Neighbor Solicitation:

Now that we have the prefix used by the network (`2a01:e34:ec15:5710::/64`),
we can add our EUI-64 and we get a IPv6 Global Unicast address:
`2a01:e34:ec15:5710:56e1:adff:feff:d478/64`.
We still have to check that this IP is unique using the DAD algorithm, and then
we're good to talk to the Internet!

The validity of this address is not limited. If a router changes prefix, it can
announce the deprecation of the old one and announce the new one, and hosts
will automatically reconfigure using the new one.

#### DHCPv6

I haven't setup a DHCPv6 server yet, so I wasn't able to perform some tests and
report them here, but basically here are the key differences between DHCPv4 and
DHCPv6:

* DHCPv6 uses DHCP Unique Identifiers (DUID) (RFC 6355) whereas DHCP for IPv4
  uses MAC addresses to identify the client;
* DHCPv6 uses ICMPv6 messages (Router Advertisement and multicast), DHCPv4 uses
  broadcast IPv4 messages on the LAN;
* DHCPv6 uses link-local IPv6 addresses when communicating between client and
  server (RFC 6939), and DHCP for IPv4 uses unsolicited broadcasts;
* Ports numbers: 67/68 for server/clients in DHCPv4 and 546/547 for
  server/clients in DHCPv6, however both use UDP.

# Wrapping up

All in all, auto-configuration in IPv6 is very promising and works quite well!

Here are some points to be explored in more details:

* Automatic DNS configuration (reporting the client's new IP to be served by
  the DNS server);
* DHCPv6 in-depth analysis;
* Improvements for the DAD algorithm in case a host is cut off the network and
  cannot invalidate an new IP corresponding to its IP.

## RFCs and bibliography

* [RFC 2462: IPv6 Stateless Address Autoconfiguration](https://tools.ietf.org/html/rfc2462)
* [RFC 4291: IP Version 6 Addressing Architecture](https://tools.ietf.org/html/rfc4291)
* [RFC 8200: Internet Protocol, Version 6 (IPv6) Specification](https://tools.ietf.org/html/rfc8200)
* [RFC 4862: IPv6 Stateless Address Autoconfiguration](https://tools.ietf.org/html/rfc4862)
* [RFC 8415: Dynamic Host Configuration Protocol for IPv6 (DHCPv6)](https://tools.ietf.org/html/rfc8415)
* [Blog Stéphane Bortzmeyer: RFC 8415: Dynamic Host Configuration Protocol for IPv6 (DHCPv6) (FR)](https://www.bortzmeyer.org/8415.html)
* ["Guidelines for Use of Extended Unique Identifier (EUI), Organizationnaly Unique Identifier (OUI), and Company ID (CID)" (PDF). IEEE Standards Association. (Page 15)](https://standards.ieee.org/content/dam/ieee-standards/standards/web/documents/tutorials/eui.pdf)
* [Keith Barker: IPv6 explained, one step at a time. (Video)](https://www.youtube.com/watch?v=rljkNMySmuM&list=PL7FBD333BAB233A44&index=1)
