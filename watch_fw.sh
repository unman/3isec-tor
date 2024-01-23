#!/bin/bash
cd /usr/lib/3isec-tor/nft
nft list table qubes-firewall > qubes
sleep 10
while true; 
do
nft list table qubes-firewall > newqubes
cmp -s qubes newqubes  || ./update_nft.sh 
sleep 10
done
