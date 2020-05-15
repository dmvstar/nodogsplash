#!/bin/sh
UPDATE=0

cd /etc/config/scripts/         || exit 0
[ -d updates ] || mkdir updates || exit 0
cd updates                      || exit 0

curl -q -OL https://github.com/dmvstar/ugb-openwrt-distro/raw/master/RT-AC51U/update.tar

if [ -f update.tar ] 
then
    md5sum  update.tar > update.tar.sum
    if [ -f update-pre.tar.sum ] 
    then
        diff update.tar.sum update-pre.tar.sum > /dev/null 2>&1
        if [ $? -eq 0 ] 
        then 
            echo SAME
            rm -f update.tar.sum update.tar; UPDATE=0; 
        else
            echo DIFF
            mv update.tar update-pre.tar
            mv update.tar.sum update-pre.tar.sum
            UPDATE=1
        fi    
    else
        mv update.tar update-pre.tar
        mv update.tar.sum update-pre.tar.sum
        UPDATE=1
    fi
else
    UPDATE=0
fi

[ $UPDATE -eq 1 ] && {
    echo UPDATE
    cd /
    tar xvf /etc/config/scripts/updates/update-pre.tar
}

sleep 5
/sbin/reboot

