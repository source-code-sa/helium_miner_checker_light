#!/bin/bash
json_temp="/tmp/data.json"
miner_vm_name=$(balena ps | /bin/egrep "miner_" | awk '{print $NF}')
# change the following for your setup
# lat=30.410314&lon
# lon=-87.219880
# Get from: https://www.latlong.net/convert-address-to-lat-long.html
# distance=10000   (this is in meters)
/usr/bin/curl -H "Content-Type: application/json" -H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:97.0) Gecko/20100101 Firefox/97.0" "https://api.helium.io/v1/hotspots/location/distance?lat=30.410314&lon=-87.219880&distance=10000" > $json_temp
readarray -t p2p_array < <(/usr/bin/jq -c '.[] | .[] | .address' $json_temp)
for addr_row in "${p2p_array[@]}"; do
  neighbour_p2p_addr='/p2p/'$(/usr/bin/jq '.' <<< "$addr_row")
  echo $neighbour_p2p_addr | tr -d '"'
  balena exec $miner_vm_name miner peer connect $(echo $neighbour_p2p_addr | tr -d '"')
wait
done
/bin/rm -rf $json_temp
