#!/bin/sh
functions_ver="Ver. 1.0.21"

sendStatus() {
      serial=$1
      S=$2
      M=$3

      D="{\"log\":{\"serial\":\"$serial\",\"status\":\"$S\",\"message\":\"$M\"}}"
      #echo $D

      curl -XPOST \
      -H "Content-type:application/json" \
      -H "x-auth-token:PTzQlEIYZVslkOyzKh41cJCfJCSuhJJ8" \
      -H "x-post-geturl:https://nr-clients.dev.ukrgasaws.com/" \
      -H "x-post-pathto:common/logger/" \
      -H "x-post-method:rt_status" \
      -d "$D" \
      https://nr-gateway.dev.ukrgasaws.com/9118aabf34299ead9f57921edb7c8209/ 2>/dev/null
      echo ""
}

getSerial() {
  serial="NONES"
  board_ugb=/etc/config/scripts/board_ugb.json

  [ -f $board_ugb ] && {
      #"serial_number":<------>"KAIWDV000912"
      serial=$(cat $board_ugb | grep "serial_numbe" | awk -F':' '{print $2}'| sed 's/[\t ", ]//g')
  }
  #echo $serial
}
