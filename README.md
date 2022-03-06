# helium_miner_checker
Low level management of your helium miner

THis is a very simplistic bash utility to run operations on your Helium miner. So far the script is specific to SenseCAP M1 devices however i do plan to add support for other brands as i further develop this applicaiton.

This application will get your miner virtual machine information, miner helium network name etc info all on its own. The idea is for the user to not have to worry about the smaller details.

Requirements:

This software does not have any pre-requisites and as such you do not need to install any 3rd party applications other than this spefific one. You will however need to have ssh access to your miner. Instructions to gain ssh access to your miner are beyond the scope of this document however you can youtube "sensecap ssh" or head on over to our discord channel https://discord.gg/GtMYeG3S to ask many of our group members to help you out.

Installation:

Please use the following commands to place this script in a persistent storage location. Script will be available across reboots however firmware updates will probably wipe the persistent storage clean. For this very reason i have kept the application as simple and straight forward as possible while using all of linux base utilities therefore no outside programs are needed. Even the method used for installation uses a base utility which will always be available in the miner.

1) SSH into your miner
2) Run the following:
                      cd /mnt/data/ && mkdir hmc_app && cd hmc_app && wget https://github.com/saad-akhtar/helium_miner_checker/hmc.sh
3) Congratulations....! Helium miner checker (HMC) is now installed and ready to rock your miner data game.....
4) To run the application is even simpler. Check out 'apprun' section below for a full list of usage commands/switches

AppRun:

Preface: (app is installed in "/mnt/data/hmc_app" location on the SD card)
1) /bin/bash /mnt/data/hmc_app.sh [option]

  [options]:
  
            * p2p-status      Get p2p status of your miner
            * gossip-peers    Print list of your Gossip Peers
            * peer-refresh    Request an updated peerbook for this peer from our gossip peers
            * relay-reset     Stop the current libp2p relay swarm and retry
            * deamon-restart  Restart the miner application instances and deamons inside the miner virtual machine. 
                              This option keeps your miner blocks current, both helium dashboard and or sensecapmx 
                              dashboard will not report any blockchain height difference nor your miner uptime on 
                              helium/sensecapmx dashboard will be disrupted.
            * vm-restart      Restart the miner virtual machine.
            * log-analyzer    Miner witness/beacon/challenger statistics
            
Usage Examples:

  /bin/bash /mnt/data/hmc_app.sh p2p-status

            +---------+-------+
            |  name   |result |
            +---------+-------+
            |connected|  yes  |
            |dialable |  yes  |
            |nat_type | none  |
            | height  |1255848|
            +---------+-------+

  /bin/bash /mnt/data/hmc_app.sh gossip-peers
  
            ["/ip4/18.228.124.125/tcp/2154","/ip4/18.228.124.125/tcp/2154",
             "/p2p/14BmPNMJvPxHMWwPkekP9AyUDVHV7DNsWkyXj9Rm4H8tqFXHYrA",
             "/p2p/1124pWscoxuyrw7zJ8h4BxQALDwsjy1TnGgacBJKSwruZPvuk8dN",
             "/p2p/11dc5RjiFGyfpR4zzMohRn7jqQoAqFfgRStiKnZUpVfK7sGAEdr"]

  /bin/bash /mnt/data/hmc_app.sh log-analyzer
  
            Total Witnessed:                                    = 76
            Successful:                                         = 6  ( 7%)
            Unreachable:                                        = 54  ( 71%)
            Send or Re-send Failed:                             = 5  ( 6%)
            Other (Witness Failures):                           = 11  ( 14%)

