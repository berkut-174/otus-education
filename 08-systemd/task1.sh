#!/bin/bash

# create config
cat > /etc/sysconfig/watchlog <<__EOF__
# Configuration file for my watchdog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
__EOF__

# create log file
cat > /var/log/watchlog.log <<__EOF__
This is a debug message
Informational message
An error has happened!
ALERT
__EOF__

# create script
cat > /opt/watchlog.sh <<__EOF__
#!/bin/bash

WORD=\$1
LOG=\$2
DATE=\$(date)
if grep \$WORD \$LOG &> /dev/null
then
logger "\$DATE: I found word, Master!"
else
exit 0
fi
__EOF__
chmod +x /opt/watchlog.sh

# create service
cat > /usr/lib/systemd/system/watchlog.service <<__EOF__
[Unit]
Description=My watchlog service
Wants=watchlog.timer

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh \$WORD \$LOG

[Install]
WantedBy=multi-user.target
__EOF__

# create timer
cat > /usr/lib/systemd/system/watchlog.timer <<__EOF__
[Unit]
Description=Run watchlog script every 30 second
Requires=watchlog.service

[Timer]
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=timers.target
__EOF__

# start timer
systemctl start watchlog.timer

# sleep 120
tail -n 20 /var/log/messages