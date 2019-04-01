#!/bin/bash

OLDSUM=`cat /var/lib/cron.md5`
NEWSUM=`md5sum /etc/crontab`

if [ "$OLDSUM" != "$NEWSUM" ]
then
md5sum /etc/crontab > /var/lib/cron.md5
echo "Subject: crontab has been modified" | sudo /usr/sbin/sendmail root
fi