#!/bin/bash
#!/bin/sh
#
# spot for varaiables that will be needed
miner_vm_name=$(balena ps | egrep "miner_" | awk '{print $NF}')
miner_animal_name=$(balena exec $miner_vm_name miner info name)
get_console_log=$(find /mnt/data -name "console.log")
total_witnesses=$(cat $get_console_log | egrep -w '@miner_onion_server:decrypt:' | grep -c ':')
successful_witnesses=$(cat $get_console_log | grep -c 'successfully sent witness to challenger')
failedtodial_witnesses=$(cat $get_console_log | grep -c 'failed to dial challenger')
resending_witnesses=$(cat $get_console_log | egrep -w '@miner_onion_server:send_witness:' | grep -c 're-sending')
sending_witnesses=$(cat $get_console_log | egrep -w '@miner_onion_server:send_witness:' | grep -c 'sending')
failedtosendresend_witnesses=$(cat $get_console_log | grep -c 'failed to send witness, max retry')
relaytransported_total=$(cat $get_console_log | egrep -w '@libp2p_transport_relay:connect_to:' | grep -c ':')
challenger_notfound=$(cat $get_console_log | egrep 'not_found' | grep -c 'failed to dial challenger')
challenger_timeout=$(cat $get_console_log | egrep 'timeout' | grep -c 'failed to dial challenger')
challenger_refused=$(cat $get_console_log | egrep 'econnrefused' | grep -c 'failed to dial challenger')
challenger_unreachable=$(cat $get_console_log | egrep 'ehostunreach' | grep -c 'failed to dial challenger')
challenger_nolistenaddr=$(cat $get_console_log | egrep 'no_listen_addr' | grep -c 'failed to dial challenger') 
#
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
	echo 'wait 30 seconds before running any further HMC commands to allow the miner deamon services to finish loading'
elif [ $1 == "vm-restart" ]; then
	balena exec $miner_vm_name miner reboot
	echo 'wait 1 minute before running any further HMC commands to allow the miner VM to boot up again and deamon services to finish loading'
elif [ $1 == "log-analyzer" ]; then
	echo '******************************************************************'
	echo 'Total Witnessed:                                    = '$total_witnesses
	echo '               |-- Sending:                         = '$(($sending_witnesses-$resending_witnesses))
	echo '               |-- Resending:                       = '$resending_witnesses
	echo 'Successful:                                         = '$successful_witnesses ' (' $(($successful_witnesses*100/$total_witnesses))'%)'
	echo 'Unreachable:                                        = '$failedtodial_witnesses ' (' $(($failedtodial_witnesses*100/$total_witnesses))'%)'
	echo 'Send or Re-send Failed:                             = '$failedtosendresend_witnesses ' (' $((failedtosendresend_witnesses*100/$total_witnesses))'%)'
	echo 'Other (Witness Failures):                           = '$(($total_witnesses-($successful_witnesses+$failedtodial_witnesses+$failedtosendresend_witnesses))) ' (' $(( ($total_witnesses-($successful_witnesses+$failedtodial_witnesses+$failedtosendresend_witnesses))*100/$total_witnesses))'%)'
	echo 'Challenger Issues:'
	echo '               |-- Challenger Not Found:            = '$challenger_notfound
	echo '               |-- Challenger Timed Out:            = '$challenger_timeout
	echo '               |-- Challenger Refused Connection:   = '$challenger_refused
	echo '               |-- Challenger Unreachable:          = '$challenger_unreachable
	echo '               |-- Challenger No Listening Address: = '$challenger_nolistenaddr
	echo '******************************************************************'
else
	echo "Bye"
fi
