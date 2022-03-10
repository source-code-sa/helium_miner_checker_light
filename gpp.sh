#!/bin/bash
#!/bin/sh
miner_vm_name=$(balena ps | egrep "miner_" | awk '{print $NF}')
var=$(balena exec $miner_vm_name miner peer gossip_peers | tr -d '[",]/p2p/' | awk '(NR>1)')
p2p='/p2p/'
for i in $var
do
	balena exec $miner_vm_name miner peer ping $p2p$i
	echo ' '
done
wait
