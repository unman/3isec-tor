#!/bin/bash
nft list ruleset > ruleset
nft list table nat > nat
nft list table qubes-firewall > qubes
/rw/config/nft/update_nat.awk nat qubes > newnat
/rw/config/nft/update_ruleset.awk  ruleset > newruleset
nft -f newruleset
rm ruleset nat qubes newnat newruleset
