#!/bin/sh

## move Kata artifacts to /opt
echo "copying kata artifacts from /tmp to /opt"
cp -R /tmp/kata/* /opt/kata/
chmod +x /opt/kata/bin/*
rm -rf /opt/kata
rm -rf /usr/share/defaults/kata-containers
rm -f /etc/containerd/config.toml

echo "Reload systemd services"
systemctl daemon-reload
systemctl restart containerd
