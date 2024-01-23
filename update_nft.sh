#!/bin/bash
cd /usr/lib/3isec-tor/nft
sed -i -f update_fw.sed newqubes
nft -f newqubes
mv newqubes qubes
