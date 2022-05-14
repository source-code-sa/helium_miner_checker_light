Helium Miner Checker Light
-- working on collecting data from my miner logs to map out all vars for light hotspot activities. Light checker will be updated here. This README will be modified to accomodate any new changes/usage instructions.

Low level management of your Light Helium Miner/Hotspot

THis is a very simplistic bash utility to run operations on your Helium miner. So far the script is specific to SenseCAP M1 devices however i do plan to add support for other brands as i further develop this applicaiton.

This application will get your miner virtual machine information, miner helium network name etc info all on its own. The idea is for the user to not have to worry about the smaller details.

Requirements:

This software does not have any pre-requisites and as such you do not need to install any 3rd party applications other than this spefific one. You will however need to have ssh access to your miner. Instructions to gain ssh access to your miner are beyond the scope of this document however you can youtube "sensecap ssh" or head on over to our discord channel https://discord.gg/GtMYeG3S to ask many of our group members to help you out.

Installation:

Please use the following commands to place this script in a persistent storage location. Script will be available across reboots however firmware updates will probably wipe the persistent storage clean. For this very reason i have kept the application as simple and straight forward as possible while using all of linux base utilities therefore no outside programs are needed. Even the method used for installation uses a base utility which will always be available in the miner.

1) SSH into your miner
2) Run the following: cd /mnt/data/ && mkdir -p hmc_app && cd hmc_app && rm -rf hmc.sh && wget https://raw.githubusercontent.com/saad-akhtar/helium_miner_checker/main/hmc.sh && rm -rf gpp.sh && wget https://raw.githubusercontent.com/saad-akhtar/helium_miner_checker/main/gpp.sh
3) Congratulations....! Helium miner checker (HMC) is now installed and ready to rock your miner data game.....
4) To run the application is even simpler. Check out 'apprun' section below for a full list of usage commands/switches

AppRun:

Preface: (app is installed in "/mnt/data/hmc_app" location on the SD card)
1) cd /mnt/data/hmc_app
2) /bin/bash hmc_app.sh [option]

  [options]:
  
            * p2p-status      Get p2p status of your miner
            * gossip-peers    Ping gossip peers and display out peer/line.
                              This switch will intiate gpp.sh and commit operation unit control is had back to hmc.sh
            * peer-refresh    Request an updated peerbook for this peer from a target gossip peer
                                    /bin/bash hmc.sh peer-refresh /p2p/112VfWsvN5PzGfH9Wxi7rnxPfsvJSxRP8JuSfRp124wRmCFRqA5Q
            * relay-reset     Stop the current libp2p relay swarm and retry
            * deamon-restart  Restart the miner application instances and deamons inside the miner virtual machine. 
                              This option keeps your miner blocks current, both helium dashboard and or sensecapmx 
                              dashboard will not report any blockchain height difference nor your miner uptime on 
                              helium/sensecapmx dashboard will be disrupted.
            * vm-restart      Restart the miner virtual machine. Seems to be most effective and also necessary after any sys.config changes.
            * w               Witness stats
            * c               Challenger stats
            * p               Peer List stats (this option will take up to 60 seconds to count your peerbook entries so please be patient)
 
3) /bin/bash gpp.sh           [if you wish to run the ping tool as standalone]
 
Usage Examples:

  /bin/bash hmc.sh p2p-status

            +---------+-------+
            |  name   |result |
            +---------+-------+
            |connected|  yes  |
            |dialable |  yes  |
            |nat_type | none  |
            | height  |1255848|
            +---------+-------+

  /bin/bash hmc.sh gossip-peers
  
            Failed to connect to "/p2p/11TUvYjiLf6UVqH9D1fBw6khuQQRAvvjerdwUxxR7wzRGJSu9": {invalid_address,
                                                                                "/p2p/11TUvYjiLf6UVqH9D1fBw6khuQQRAvvjerdwUxxR7wzRGJSu9"}
            Failed to connect to "/p2p/11CPdgTQrFbxK48DKHVAhDicDcmBYRLkASRo57qr14MbDjvJ": {invalid_address,
                                                                                           "/p2p/11CPdgTQrFbxK48DKHVAhDicDcmBYRLkASRo57qr14MbDjvJ"}
            Pinged "/p2p/11RhXn1sMPPiDWMPr3nSfVtJuWjTQbedRBQZF43y6MnZad1MFKJ" successfully with roundtrip time: 60 ms
            Failed to connect to "/p2p/11bKRgGCRQXnbZya6APeC17hM4Pa3NQs4VMX6fygEhi3kPNtJPm": {invalid_address,
                                                                                              "/p2p/11bKRgGCRQXnbZya6APeC17hM4Pa3NQs4VMX6fygEhi3kPNtJPm"}
            Pinged "/p2p/11LTBxQ8NqMFBGtDF7UZ7rDbdhHzcDt7MHqkVDqRdn8CxwBVgkt" successfully with roundtrip time: 291 ms
            Failed to connect to "/p2p/11gi3c3XPQUKB8LrB58BqLqdNtCsgdMuieF8JwASH5NUWSu1": {invalid_address,
                                                                                           "/p2p/11gi3c3XPQUKB8LrB58BqLqdNtCsgdMuieF8JwASH5NUWSu1"}

  /bin/bash hmc.sh w
  
            ****************************************************************************
            Performing actions on Node:
                      VM: miner_4633499_2090301
             Animal Name: soaring-champagne-jellyfish
            Log Location: /mnt/data/docker/volumes/1851574_miner-log/_data/console.log
            ****************************************************************************

            ******************************************************************

            Total Witnessed:                                    = 9
                           |-- Sending:                         = 7
                           |-- Times Retried:                   = 22
            Successful:                                         = 5  ( 55%)
            Unreachable:                                        = 5  ( 55%)
            Send or Re-send Failed:                             = 2  ( 0%)
            Other (Witness Failures):                           = 0  ( 0%)


  /bin/bash hmc.sh c
  
            ****************************************************************************
            Performing actions on Node:
                      VM: miner_4633499_2090301
             Animal Name: soaring-champagne-jellyfish
            Log Location: /mnt/data/docker/volumes/1851574_miner-log/_data/console.log
            ****************************************************************************

            ******************************************************************

            Challenger Issues:
                           |-- Challenger Not Found:            = 3
                           |-- Challenger Timed Out:            = 19
                           |-- Challenger Refused Connection:   = 0
                           |-- Challenger Unreachable:          = 0
                           |-- Challenger No Listening Address: = 0
                           

  /bin/bash hmc.sh p
  
            ****************************************************************************
            Performing actions on Node:
                      VM: miner_4633499_2090301
             Animal Name: soaring-champagne-jellyfish
            Log Location: /mnt/data/docker/volumes/1851574_miner-log/_data/console.log
            ****************************************************************************

            ******************************************************************
            Total Peer Activity:                                = 170
                           |-- Timeouts:                        = 77  ( 45%)
                           |-- Proxy Session Timeouts:          = 0  ( 0%)
                           |-- Relay Session Timeouts:          = 26  ( 15%)
                           |-- Normal Exit:                     = 33  ( 19%)
                           |-- Not Found:                       = 65  ( 38%)
                           |-- Server Down:                     = 1  ( 0%)
                           |-- Failed to Dial Proxy:            = 0  ( 0%)
                           |-- Connection Refused:              = 0  ( 0%)
                           |-- Connection Closed:               = 8  ( 4%)

            ******************************************************************
          
          
