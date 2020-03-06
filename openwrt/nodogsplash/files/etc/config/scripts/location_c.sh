#!/bin/sh

# getip
publicIP=`curl -s https://ipinfo.io/ip`

#call geolocation API
locationJSON=`curl -s https://ipvigilante.com/$publicIP`
loc=`echo $locationJSON | sed 's:^.::'`
MAC=`ifconfig eth0 | grep "eth0" | awk '{print $5}'`
locationJSONMAC="{\"phone\":\"380632552582\",\"mac\":\"$MAC\",$loc"
echo $locationJSONMAC
#call nr-sandbox
echo $locationJSONMAC #> location_c.json
curl -X POST -H "Content-Type:application/json" --data "$locationJSONMAC" https://nr-sandbox.stage.digitalind.net/WiFi/location
