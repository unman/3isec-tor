TorVM (3isec-tor)
==========================

TorVM is a ProxyVM service that provides torified networking to all its
clients.

By default, any qube using the TorVM as its NetVM will be fully torified, so
that even applications that are not Tor aware  will be forced to use Tor.

Moreover, qubes running behind a TorVM are not able to access globally
identifying information (IP address and MAC address).

Due to the nature of the Tor network, only IPv4 TCP and DNS traffic is allowed.
All non-DNS UDP and IPv6 traffic is silently dropped.

See [this article](http://theinvisiblethings.blogspot.com/2011/09/playing-with-qubes-networking-for-fun.html) for a description of the concept, architecture, and the original implementation.

## Warning + Disclaimer

1. TorVM is produced independently from the Tor(R) anonymity software and
   carries no guarantee from The Tor Project about quality, suitability or
   anything else.

2. TorVM is not a magic anonymizing solution. Protecting your identity
   requires a change in behavior. Read the "Protecting Anonymity" section
   below.

3. NO traffic originating from the TorVM is allowed, except traffic running
   under the Tor user. NO traffic is forwarded through the TorVM.

4. TorVM is integrated with the Qubes firewall.
   Changes in the Qubes firewall are propogated to a filter on the PREROUTING hook.
   DNS from clients is allowed by default, and passed through Tor. ICMP is blocked.
   The natural way to do this would have been using qubes-firewall-user-script, but in 4.0 this script only runs at qube start.
   The solution is to check for changes in the qubes-firewall table, and write them in to the nat table: the check runs every 15 secs.
  

Installation
============


0. *(Optional)* If you want to use a separate vm template for your TorVM

        qvm-clone debian-10 debian10-tor

1. In dom0, create a proxy vm, disable unnecessary services, and enable 3isec-tor


        qvm-create -p torvm -l red
        qvm-service torvm -d qubes-netwatcher
        qvm-service torvm -d qubes-firewall
        qvm-service torvm -e 3isec-tor
          
        # if you  created a new template in the previous step
        qvm-prefs torvm template debian10-tor

2. Set prefs of torvm to use your default netvm or firewallvm as its NetVM

3. In the template, add the 3isec repositories:

        sudo echo "deb https://qubes.3isec.org/4.0 stretch main

4. In the template, install the 3isec-tor package

        sudo apt install 3isec-tor

5. Shutdown the template.

6. Configure a qube to use torvm as its netvm (e.g using a qube named anon-web)

        qvm-prefs anon-web netvm torvm
        ... repeat for other qubes ...

7. Start torvm and any qube configured to use it.

8. From the qube, verify torified connectivity

        w3m https://check.torproject.org


### Troubleshooting ###


1. Check if the 3isec-tor service is running (in the torvm)

        [user@torvm] $ sudo systemctl status 3isec-tor

2. Tor logs to syslog, so to view messages use

        [user@torvm] $ sudo grep Tor /var/log/messages

3. Open nyx, and look at messages and circuits

4. Restart the 3isec-tor service (and repeat 1-2)

        [user@torvm] $ sudo systemctl restart 3isec-tor

Usage
=====

Applications should "just work" behind a TorVM, however there are some steps
you can take to protect anonymity and increase performance.

## Protecting Anonymity

The TorVM only purports to prevent the leaking of two identifiers:

1. WAN IP Address
2. NIC MAC Address

This is accomplished through transparent TCP and transparent DNS proxying by
the TorVM.

The TorVM cannot anonymize information stored or transmitted from your qubes
behind the TorVM. 

*Non-comprehensive* list of identifiers TorVM does not protect:

* Time zone
* User names and real name
* Name+version of any client (e.g. IRC leaks name+version through CTCP)
* Metadata in files (e.g., exif data in images, author name in PDFs)
* License keys of non-free software

### Further Reading

* [Information on protocol leaks](https://trac.torproject.org/projects/tor/wiki/doc/TorifyHOWTO#Protocolleaks)
* [Official Tor Usage Warning](https://www.torproject.org/download/download-easy.html.en#warning)
* [Tor Browser Design](https://www.torproject.org/projects/torbrowser/design/)


## Performance

In order to mitigate identity correlation TorVM makes use of Tor's [stream
isolation feature][stream-isolation]. Read "Threat Model" below for more
information.

However, this isn't desirable in all situations, particularly web browsing.
These days loading a single web page requires fetching resources (images,
javascript, css) from a dozen or more remote sources. Moreover, the use of
IsolateDestAddr in a modern web browser may create very uncommon HTTP behavior
patterns, that could ease fingerprinting.

Additionally, you might have some apps that you want to ensure always share a
Tor circuit or always get their own.

For these reasons TorVM ships with two open SOCKS5 ports that provide Tor
access with different stream isolation settings:

* Port 9050 - Isolates by SOCKS Auth and client address only  
              Each qube gets its own circuit, and each app using a unique SOCKS
              user/pass gets its own circuit
* Port 9049 - Isolates client + destination port, address, and by SOCKS Auth
              Same as default settings listed above, but additionally traffic
              is isolated based on destination port and destination address.


## Custom Tor Configuration

Default tor settings are found in the following file and are the same across
all TorVMs.

      /usr/lib/3isec-tor/torrc

You can override these settings in your TorVM, or provide your own custom
settings by appending them to:

      /rw/config/3isec-tor/torrc

For information on tor configuration settings `man tor`

Threat Model
============

TorVM assumes the same Adversary Model as [TorBrowser][tor-threats], but does
not, by itself, have the same security and privacy requirements.

## Proxy Obedience

The primary security requirement of TorVM is *Proxy Obedience*.

Client qubes MUST NOT bypass the Tor network and access the local physical
network, internal Qubes network, or the external physical network.

Proxy Obedience is assured through the following:

1. All TCP traffic from client VMs is routed through Tor
2. All DNS traffic from client VMs is routed through Tor
3. All non-DNS UDP traffic from client VMs is dropped
4. Reliance on the [Qubes OS network model][qubes-net] to enforce isolation

## Mitigate Identity Correlation

TorVM SHOULD prevent identity correlation among network services.

Without stream isolation, all traffic from different activities or "identities"
in different applications (e.g., web browser, IRC, email) end up being routed
through the same Tor circuit. An adversary could correlate this activity to a
single pseudonym.

TorVM uses the default stream isolation settings for transparently torified
traffic. While more paranoid options are available, they are not enabled by
default because they decrease performance and in most cases don't help
anonymity (see [this tor-talk thread][stream-isolation-explained])

By default TorVM does not use the most paranoid stream isolation settings for
transparently torified traffic due to performance concerns. By default TorVM
ensures that each qube will use a separate Tor circuit (`IsolateClientAddr`).

For more paranoid use cases the SOCKS proxy port 9049 is provided: this has all
stream isolation options enabled. User applications will require manual
configuration to use this socks port.


Future Work
===========
* Use local DNS cache to speedup queries (pdnsd)
* Support arbitrary [DNS queries][dns]
* Fix Tor's openssl complaint
* Support custom firewall rules (to support running a relay)

Acknowledgments
================

3isec-tor has been forked from the defunct [Qubes TorVM project][qubestor]
All credit to the contributors to that project.

[stream-isolation]: https://gitweb.torproject.org/torspec.git/blob/HEAD:/proposals/171-separate-streams.txt
[stream-isolation-explained]: https://lists.torproject.org/pipermail/tor-talk/2012-May/024403.html
[tor-threats]: https://www.torproject.org/projects/torbrowser/design/#adversary
[qubes-net]: https://theinvisiblethings.blogsplot.com/2011/09/playing-with-qubes-networking-for-fun.html
[dns]: https://tails.boum.org/todo/support_arbitrary_dns_queries/
[qubestor]: https://github.com/QubesOS/qubes-app-linux-tor

