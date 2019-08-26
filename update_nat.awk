#!/usr/bin/awk -f
/table ip nat/
{if ( /forward/ && ARGIND==1 ) {
  nextfile
}}
{{sub(/priority 0/,"priority -200" )}}
/10.139.1.1/{next}
/icmp accept/{next}
/iifname/{next}
{{sub(/hook forward/,"hook prerouting")}}
{{sub(/established,related/,"established")}}
{{sub(/established,related/,"established")}}
/chain/,/\t}/
END {print "}" }
