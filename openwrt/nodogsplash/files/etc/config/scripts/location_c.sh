#!/bin/sh

# getip
publicIP=`curl -s https://ipinfo.io/ip`

#call geolocation API
locationJSON=`curl -s https://ipvigilante.com/$publicIP`
loc=`echo $locationJSON | sed 's:^.::'`

MAC=`ifconfig | egrep "eth0|wlp2s0" | awk '{print $5}'`

if [ -f /etc/config/scripts/board_ugb.json ]
then
    board_ugb=$(cat /etc/config/scripts/board_ugb.json)
    board_ver=$(cat /etc/config/scripts/version_ugb)
    locationJSONMAC="{\"board\":$board_ugb,\"version\":\"$board_ver\",\"mac\":\"$MAC\",$loc"
else
    locationJSONMAC="{\"phone\":\"380632552582\",\"mac\":\"$MAC\",$loc"
fi

echo $locationJSONMAC

#call nr-sandbox
#echo $locationJSONMAC #> location_c.json
##curl -X POST -H "Content-Type:application/json" --data "$locationJSONMAC" https://nr-sandbox.stage.digitalind.net/WiFi/location
