#!/bin/sh

echo "Start"

[ -f /etc/config/scripts/board_ugb.json ] && {
    echo "Update Mac"
    [ -f /etc/config/scripts/board_ugb.json.old ] || cp /etc/config/scripts/board_ugb.json /etc/config/scripts/board_ugb.json.old
    
    #linux
    MAC=`ifconfig | egrep "eth0|wlp2s0|wlp3s0" | awk '{print $5}'`
    MAC=`ifconfig wlp3s0 | grep "ether" | awk '{print $2}' `
    #openwrt
    [ -f /etc/board.json ] && MAC=`ifconfig eth0 | grep "eth0" | awk '{print $5}'`

    echo $MAC

    cat /etc/config/scripts/board_ugb.json | 
    sed "s/.*\"serial_number\":.*/\t\"serial_number\":\t\"${MAC}\",/" > /etc/config/scripts/board_ugb.json.new
    [ -z /etc/config/scripts/board_ugb.json.new ] || {
      echo Ok
      mv /etc/config/scripts/board_ugb.json.new /etc/config/scripts/board_ugb.json
    }

}