#!/usr/bin/awk -f
/table ip nat/
{if ( /forward/ && ARGIND==1 ) {
  nextfile
}}
{{sub(/priority 0/,"priority -200" )}}
/tcp dport domain/{next}
{{sub(/.*10.*udp dport domain/,"udp dport domain" )}}
/icmp accept/{next}
/admin-prohibited/{next}
{{sub(/hook forward/,"hook prerouting")}}
{{sub(/established,related/,"established")}}
{{sub(/established,related/,"established")}}
/chain/,/\t}/
END {print "}" }
