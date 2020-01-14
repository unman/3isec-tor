#!/bin/bash
cd /usr/lib/3isec-tor/nft
<<<<<<< HEAD
nft list ruleset > ruleset
nft list table nat > nat
nft list table qubes-firewall > qubes
/usr/lib/3isec-tor/nft/update_nat.awk nat qubes > newnat
/usr/lib/3isec-tor/nft/update_ruleset.awk  ruleset > newruleset
nft -f newruleset
rm ruleset nat newnat newruleset
sleep 30
while true; 
do
nft list table qubes-firewall > newqubes
cmp -s qubes newqubes  || ./update_nft.sh 
=======
while true;
do
nft list table qubes-firewall > newqubes
cmp -s qubes newqubes  || ./update_nft.sh
>>>>>>> 607004b5c3ed128abb460df33cacf9a96147bd1c
rm newqubes
sleep 30
done
