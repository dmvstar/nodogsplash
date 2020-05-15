#!/bin/sh

UPDATE=0

cd /etc/config/scripts/         || exit 0
[ -d updates ] || mkdir updates || exit 0
cd updates                      || exit 0

checkUpdates() {

    fileExt=$1
    fileNam=$(basename $1 .tar)
    filePre=$fileNam-pre.tar

    cd /etc/config/scripts/updates || exit 0

    echo $fileExt

    curl -q -OL https://github.com/dmvstar/ugb-openwrt-distro/raw/master/RT-AC51U/$fileExt > /dev/null 2>&1

    if [ -f $fileExt ] 
    then
        md5sum  $fileExt | awk '{print $1}' > $fileExt.sum
        if [ -f $filePre.sum ] 
        then
            diff $fileExt.sum $filePre.sum > /dev/null 2>&1
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

checkUpdates update.tar

board_ugb=/etc/config/scripts/board_ugb.json

[ -f $board_ugb ] && {
    #"serial_number":<------>"KAIWDV000912"
    serial=$(cat $board_ugb | grep "serial_numbe" | awk -F':' '{print $2}'| sed 's/[", ]//g')
    update=$serial-update.tar
    checkUpdates $update
}


#sleep 5
/sbin/reboot

