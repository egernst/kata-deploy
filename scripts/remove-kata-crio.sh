#!/bin/sh
echo "deleting kata artifacts"
rm -rf /opt/kata/
rm -rf /usr/sahre/defaults/kata-containers

mv /etc/crio/crio.conf.bak /etc/crio/crio.conf

echo "Reload systemd services"
systemctl daemon-reload
systemctl restart crio
