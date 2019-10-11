#!/bin/bash
cd /usr/lib/3isec-tor/nft
while true;
do
nft list table qubes-firewall > newqubes
cmp -s qubes newqubes  || ./update_nft.sh
rm newqubes
sleep 30
done
