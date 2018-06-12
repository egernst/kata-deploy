#!/bin/sh
echo "delete kata artifacts"
rm -rf /opt/kata
rm -rf /usr/share/defaults/kata-containers
rm -f /etc/containerd/config.toml

echo "Reload systemd services"
systemctl daemon-reload
systemctl restart containerd
