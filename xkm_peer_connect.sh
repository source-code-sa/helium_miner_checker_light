#!/bin/bash
xkm_distance="20000" # in meters, so 10000m = 10 kilometers
xkm_lon="-87.219880"
xkm_lat="30.410314"
json_temp="/tmp/data.json"
/bin/rm -rf $json_temp
miner_vm_name=$(balena ps | /bin/egrep "miner_" | awk '{print $NF}')
wait
rm -rf /var/data/*.db
rm -rf /var/data/blockchain_swarm
wait
balena exec $miner_vm_name miner peer relay_reset
wait
success_counter=0
failure_counter=0
/usr/bin/curl -H "Content-Type: application/json" -H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:97.0) Gecko/20100101 Firefox/97.0" "https://api.helium.io/v1/hotspots/location/distance?lat=$xkm_lat&lon=$xkm_lon&distance=$xkm_distance" > $json_temp
readarray -t p2p_array < <(/usr/bin/jq -c '.[] | .[] | .address' $json_temp)
for addr_row in "${p2p_array[@]}"; do
  neighbour_p2p_addr='/p2p/'$(/usr/bin/jq '.' <<< "$addr_row")
  if [[ $(balena exec $miner_vm_name miner peer ping $(echo $neighbour_p2p_addr | tr -d '"') | grep "successfully with roundtrip time") ]]; then
    balena exec $miner_vm_name miner peer connect $(echo $neighbour_p2p_addr | tr -d '"')
    wait
    (( success_counter++ ))
  else
    (( failure_counter++ ))
  fi
done
/bin/rm -rf $json_temp
echo 'Successful = '$success_counter
echo 'Failures   = '$failure_counter
