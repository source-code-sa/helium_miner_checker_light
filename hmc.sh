#!/bin/bash
#!/bin/sh
#
# if/elif/else to check if any switches are passed
#if [ -z "$1" ]; then
#	echo "null"
#else
#	echo "not...."
#fi
miner_vm_name=$(balena ps | egrep "miner_" | awk '{print $NF}')
wait -f
miner_animal_name=$(balena exec $miner_vm_name miner info name)
wait -f
get_console_log=$(find /mnt/data -name "console.log")
#mapfile -t console_log < <( $get_console_log )
wait -f
total_witnesses=$(cat $get_console_log | egrep -w '@miner_onion_server_light:decrypt:' | egrep -w '240,13' | grep -c ':')
echo "**************************************************************************************"
echo "HMC - Helium Miner Checker (https://github.com/saad-akhtar/helium_miner_checker_light)"
echo "           VM: $miner_vm_name"
echo "  Animal Name: $miner_animal_name"
echo " Log Location: $get_console_log"
echo "       Uptime:"$(uptime)
echo 'Log Timestamp: '$(date)
printf "**************************************************************************************\n"
if [ $1 == "p2p-status" ]; then
	balena exec $miner_vm_name miner info p2p_status
elif [ $1 == "gossip-peers" ]; then
	/bin/bash $(pwd)/gpp.sh
elif [ $1 == "peer-refresh" ]; then
	balena exec $miner_vm_name miner peer refresh
elif [ $1 == "relay-reset"  ]; then
	balena exec $miner_vm_name miner peer relay_reset
elif [ $1 == "deamon-restart" ]; then
	balena exec $miner_vm_name miner restart
	echo 'wait 30 seconds before running any further HMC commands to allow the miner deamon services to finish loading'
elif [ $1 == "vm-restart" ]; then
	balena exec $miner_vm_name miner reboot
	printf "Restarting Miner Virtual Machine. This will initiate a restart countdown"
	wait -f
	printf "\nRestart complete !!!\n"
	printf '\nPlease wait approx 1 minute before running any further HMC commands to allow the miner VM to boot up again and deamon services to finish loading.\n\n'
# witnesses
elif [ $1 == "w" ]; then	
	successful_witnesses=$(cat $get_console_log | grep 'blockchain_poc_witness' | egrep -w '392.5' | grep -c ':')
	successful_witnesses_perc=$(($successful_witnesses*100/$total_witnesses))
# This is a challenger issue and not witness
#	failedtodial_witnesses=$(cat $get_console_log | egrep -w 'failed to dial challenger' | awk -F'>' '{print $2,$9}' | sort -u | grep -c ':')
#	failedtodial_witnesses_perc=$(($failedtodial_witnesses*100/$total_witnesses))
	base_resending_witnesses=$(cat $get_console_log | egrep -w '@miner_onion_server:send_witness:' | grep -c 're-sending')
	resending_witnesses=$((${base_resending_witnesses:0:${#base_resending_witnesses}-1}+${base_resending_witnesses:${#base_resending_witnesses}-1}))
	sending_witnesses=$(cat $get_console_log | egrep -w '@miner_onion_server:send_witness:' | grep -c 'sending')
	failedtosendresend_witnesses=$(cat $get_console_log | grep -c 'failed to send witness, max retry')
#	failedtosendresend_witnesses_perc=$(($failedtosendresend_witnesses*100/$total_witnesses))
	sending_witnesses_sum=$(($sending_witnesses-$resending_witnesses))
#	other_witness_failure_perc=$(($sending_witnesses_sum-($failedtodial_witnesses+$failedtosendresend_witnesses)*100/$total_witnesses))
	echo "--------------------------------------------------------------------------------------"
	echo 'Total Witnessed:                                    = '$total_witnesses
	echo '               |-- Sent:                            = '$sending_witnesses_sum
	echo '               |-- Retries (sending):               = '$resending_witnesses
	echo '               |-- Max Retry Failures               = '$failedtosendresend_witnesses
	echo 'Successful:                                         = '$successful_witnesses ' (' $successful_witnesses_perc'%)'
# This is mostly a challenger error and not a witness issue so its a small offset in actual final counts
#	echo 'Unreachable:                                        = '$failedtodial_witnesses ' (' $failedtodial_witnesses_perc'%)'
	echo 'Total Failed Witnesses:                             = '$(($total_witnesses-$successful_witnesses)) ' ('$((($total_witnesses-$successful_witnesses)*100/$total_witnesses))'%)'
#	echo 'Other (Witness Failures):                           = '$(($sending_witnesses_sum-($failedtodial_witnesses+$failedtosendresend_witnesses))) ' (' $other_witness_failure_perc'%)'
	echo ''
# challenger
elif [ $1 == "c" ]; then
   challenger_notfound=$(cat $get_console_log | egrep 'not_found' | grep -c 'failed to dial challenger')
	challenger_timeout=$(cat $get_console_log | egrep 'timeout' | grep -c 'failed to dial challenger')
	challenger_refused=$(cat $get_console_log | egrep 'econnrefused' | grep -c 'failed to dial challenger')
	challenger_unreachable=$(cat $get_console_log | egrep 'ehostunreach' | grep -c 'failed to dial challenger')
	challenger_nolistenaddr=$(cat $get_console_log | egrep 'no_listen_addr' | grep -c 'failed to dial challenger')
   echo "--------------------------------------------------------------------------------------"
   echo 'Challenger Issues:'
   echo '               |-- Challenger Not Found:            = '$challenger_notfound
   echo '               |-- Challenger Timed Out:            = '$challenger_timeout
   echo '               |-- Challenger Refused Connection:   = '$challenger_refused
   echo '               |-- Challenger Unreachable:          = '$challenger_unreachable
   echo '               |-- Challenger No Listening Address: = '$challenger_nolistenaddr
   echo ''
	echo '**************************************************************************************'
# Peer Activity
elif [ $1 == "p" ]; then
	peer_activity_list=$(cat $get_console_log | egrep -w '@libp2p_group_worker:connecting:' | grep -c ':')
	peer_normal_exit=$(cat $get_console_log | egrep '@libp2p_group_worker:connecting:' | grep -c 'exit,{normal')
	peer_timeout=$(cat $get_console_log | egrep '@libp2p_group_worker:connecting:' | grep -c 'timeout')
	peer_timeout_proxy_session=$(cat $get_console_log | egrep '@libp2p_group_worker:connecting:' | grep -c 'timeout_proxy_session')
	peer_timeout_relay_session=$(cat $get_console_log | egrep '@libp2p_group_worker:connecting:' | grep -c 'timeout_relay_session')
	peer_closed=$(cat $get_console_log | egrep '@libp2p_group_worker:connecting:' | grep -c 'closed')
	peer_not_found=$(cat $get_console_log | egrep '@libp2p_group_worker:connecting:' | grep -c 'not_found')
	peer_server_down=$(cat $get_console_log | egrep '@libp2p_group_worker:connecting:' | grep -c 'server_down')
	peer_fail_dial_proxy=$(cat $get_console_log | egrep '@libp2p_group_worker:connecting:' | grep -c 'fail_dial_proxy')
	peer_econnrefused=$(cat $get_console_log | egrep '@libp2p_group_worker:connecting:' | grep -c 'econnrefused')
	wait -f
	printf 'Standby as we sum up your miner peerbook density\n'
	peer_book_size=$(balena exec $miner_vm_name miner peer book -c)
	wait -f
   echo "--------------------------------------------------------------------------------------"
   echo 'Total Peer Activity:                                = '$peer_activity_list
   echo '               |-- Timeouts:                        = '$peer_timeout #' (' $(( ($peer_timeout*100)/$peer_activity_list ))'%)'
   echo '               |-- Proxy Session Timeouts:          = '$peer_timeout_proxy_session #' (' $(( ($peer_timeout_proxy_session*100)/$peer_activity_list ))'%)'
   echo '               |-- Relay Session Timeouts:          = '$peer_timeout_relay_session #' (' $(( ($peer_timeout_relay_session*100)/$peer_activity_list ))'%)'
   echo '               |-- Normal Exit:                     = '$peer_normal_exit #' (' $(( ($peer_normal_exit*100)/$peer_activity_list ))'%)'
   echo '               |-- Not Found:                       = '$peer_not_found #' (' $(( ($peer_not_found*100)/$peer_activity_list ))'%)'
   echo '               |-- Server Down:                     = '$peer_server_down #' (' $(( ($peer_server_down*100)/$peer_activity_list ))'%)'
   echo '               |-- Failed to Dial Proxy:            = '$peer_fail_dial_proxy #' (' $(( ($peer_fail_dial_proxy*100)/$peer_activity_list ))'%)'
   echo '               |-- Connection Refused:              = '$peer_econnrefused #' (' $(( ($peer_econnrefused*100)/$peer_activity_list ))'%)'
   echo '               |-- Connection Closed:               = '$peer_closed #' (' $(( ($peer_closed*100)/$peer_activity_list ))'%)'
	echo 'Peer Book Size:                                     = '$peer_book_size
   echo ''
	echo '**************************************************************************************'	
else
	echo "Bye"
fi
#relaytransported_total=$(cat $get_console_log | egrep -w '@libp2p_transport_relay:connect_to:' | grep -c ':')
#
#
