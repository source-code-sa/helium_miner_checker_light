#!/bin/bash
#!/bin/sh
#
# spot for varaiables that will be needed
miner_vm_name=$(balena ps | grep "miner_" | awk -F' ' '{print $10}')
miner_animal_name=$(balena exec $miner_vm_name miner info name)
#device_address=$(curl -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Content-Type: application/json" -H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:97.0) Gecko/20100101 Firefox/97.0" https://api.helium.io/v1/hotspots/name/$miner_animal_name | awk -F'":"' '{print $20}' | rev | cut -c5- | rev)
get_console_log=$(find /mnt/data -name "console.log")
total_witnesses=$(cat $get_console_log | grep -c 'sending witness at RSSI')
successful_witnesses=$(cat $get_console_log | grep -c 'successfully sent witness to challenger')
failedtodial_witnesses=$(cat $get_console_log | grep -c 'failed to dial challenger')
failedtosendresend_witnesses=$(cat $get_console_log | grep -c 'failed to send witness, max retry')
#
echo "****************************************************************************"
echo "Performing actions on Node:"
echo "          VM: $miner_vm_name"
echo " Animal Name: $miner_animal_name"
echo "Log Location: $get_console_log"
echo "****************************************************************************"
echo " "
#
if [ $1 == "p2p-status" ]; then
	balena exec $miner_vm_name miner info p2p_status
elif [ $1 == "gossip-peers" ]; then
	balena exec $miner_vm_name miner peer gossip_peers
elif [ $1 == "peer-refresh" ]; then
	balena exec $miner_vm_name miner peer refresh
elif [ $1 == "relay-reset"  ]; then
	balena exec $miner_vm_name miner peer relay_reset
elif [ $1 == "deamon-restart" ]; then
	balena exec $miner_vm_name miner restart
elif [ $1 == "vm-restart" ]; then
	balena exec $miner_vm_name miner reboot
elif [ $1 == "log-analyzer" ]; then
	echo '******************************************************************'
	echo 'Total Witnessed:                                    = '$total_witnesses
	echo 'Successful:                                         = '$successful_witnesses ' (' $(($successful_witnesses*100/$total_witnesses))'%)'
	echo 'Unreachable:                                        = '$failedtodial_witnesses ' (' $(($failedtodial_witnesses*100/$total_witnesses))'%)'
	echo 'Send or Re-send Failed:                             = '$failedtosendresend_witnesses ' (' $((failedtosendresend_witnesses*100/$total_witnesses))'%)'
	echo 'Other (Witness Failures):                           = '$(($total_witnesses-($successful_witnesses+$failedtodial_witnesses+$failedtosendresend_witnesses))) ' (' $(( ($total_witnesses-($successful_witnesses+$failedtodial_witnesses+$failedtosendresend_witnesses))*100/$total_witnesses))'%)'
	echo '******************************************************************'
else
	echo "Bye"
fi
