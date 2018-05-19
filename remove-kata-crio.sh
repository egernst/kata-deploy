#!/bin/sh

## move Kata artifacts to /opt
echo "copying kata artifacts from /tmp to /opt"
rm -rf /opt/kata/
rm -rf /usr/sahre/defaults/kata-containers

crio_config_file="/etc/crio/crio.conf"

cp $crio_config_file $crio_config_file.bak

mv /etc/crio/crio.conf.bak /etc/crio/crio.conf

echo "Reload systemd services"

systemctl daemon-reload
systemctl restart crio
