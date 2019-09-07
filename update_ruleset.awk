#!/usr/bin/awk -f
BEGIN { 
	{print "flush ruleset"}
	{print "include \"/usr/lib/3isec-tor/nft/newnat\" "}

}
	/table ip nat {/,/^}/ {next}
	{print}
