#!/bin/sh
ver="Ver. 1.0.21"

[ -f /etc/config/scripts/functions.sh ] &&
{
  . /etc/config/scripts/functions.sh
}

UPDATE=0

cd /etc/config/scripts/         || exit 0
[ -d updates ] || mkdir updates || exit 0
cd updates                      || exit 0

#linux
MAC=`ifconfig | egrep "eth0|wlp2s0" | awk '{print $5}'`
#openwrt
[ -f /etc/board.json ] && MAC=`ifconfig eth0 | grep "eth0" | awk '{print $5}'`


checkUpdates() {

    fileExt=$1
    fileNam=$(basename $1 .tar)
    filePre=$fileNam-pre.tar

    cd /etc/config/scripts/updates || exit 0

    echo $fileExt

    curl -q -OL https://github.com/dmvstar/ugb-openwrt-distro/raw/master/RT-AC51U/$fileExt > /dev/null 2>&1

    if [ -f $fileExt ]
    then
        #echo $fileExt.sum $filePre.sum
        md5sum  $fileExt | awk '{print $1}' > $fileExt.sum
        #ls -l $fileExt.sum $filePre.sum
        if [ -f $filePre.sum ]
        then
            diff $fileExt.sum $filePre.sum #> /dev/null 2>&1
            if [ $? -eq 0 ]
            then
                echo "  SAME"
                rm -f $fileExt.sum $fileExt; UPDATE=0;
            else
                echo "  DIFF"
                mv $fileExt     $filePre
                mv $fileExt.sum $filePre.sum
                UPDATE=1
            fi
        else
            mv $fileExt     $filePre
            mv $fileExt.sum $filePre.sum
            UPDATE=1
        fi
    else
        mv $fileExt     $filePre
        mv $fileExt.sum $filePre.sum
        UPDATE=1
    fi

    [ $UPDATE -eq 1 ] && {
        echo "      UPDATE"
        cd /
        tar xvf /etc/config/scripts/updates/$filePre 2>/dev/null
    }
}

checkDiff() {
  which diff >/dev/null 2>&1
  [ $? -ne 0 ] && {
    echo "opkg update"
    opkg update
    opkg install diffutils
  }
}

echo "-------------------------------------------------------" > /etc/config/scripts/update.log
echo $ver >> /etc/config/scripts/update.log
date  >> /etc/config/scripts/update.log

checkDiff

checkUpdates update.tar   >> /etc/config/scripts/update.log

board_ugb=/etc/config/scripts/board_ugb.json
post_update=/etc/config/scripts/post_update.sh
serial="NONE0"

getSerial

update=$serial-update.tar
checkUpdates $update  >> /etc/config/scripts/update.log

#[ -f $board_ugb ] && {
    #"serial_number":<------>"KAIWDV000912"
#    serial=$(cat $board_ugb | grep "serial_numbe" | awk -F':' '{print $2}'| sed 's/[\t ", ]//g')
#    update=$serial-update.tar
#    checkUpdates $update  >> /etc/config/scripts/update.log
#}

sendStatus $serial $MAC "UPDATE" "Обновления для RT-AC51U $(date)"

[ -f $post_update ] && {
    sh $post_update
    rm $post_update
}

#sleep 5
#sendStatus $serial "LOG" "$(cat /etc/config/scripts/update.log)"
sendStatus $serial $MAC "REBOOT" "Перезагрузка... work $(uptime) date $(date)"
/sbin/reboot

echo "-------------------------------------------------------" >> /etc/config/scripts/update.log

cat /etc/config/scripts/update.log
