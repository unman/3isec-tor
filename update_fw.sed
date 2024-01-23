#!/usr/bin/sed -f 
1 i flush table qubes-prerouting-firewall 
s/qubes-firewall/qubes-prerouting-firewall/
s/hook forward priority filter/hook prerouting priority -200/
/iifname/ d
/oifname/ d
/chain prerouting/, /}/ d
/chain postrouting/, /}/ d

/filter hook prerouting/a iifname != "vif*" accept
s/established,related/established/
/10.139.1.1-10.139.1.2/ d
/protocol icmp accept/ d
/reject with icmp admin-prohibited/ d
