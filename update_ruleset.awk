#!/usr/bin/awk -f
BEGIN { 
	{print "flush ruleset"}
	{print "include \"/rw/config/newnat\" "}

}
	/table ip nat {/,/^}/ {next}
	{print}
