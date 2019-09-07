#!/bin/bash
cd /usr/lib/3isec-tor/nft
nft list ruleset > ruleset
nft list table nat > nat
nft list table qubes-firewall > qubes
/usr/lib/3isec-tor/nft/update_nat.awk nat qubes > newnat
/usr/lib/3isec-tor/nft/update_ruleset.awk  ruleset > newruleset
nft -f newruleset
rm ruleset nat newnat newruleset
