#!/bin/sh
echo "copying kata artifacts from /tmp to /opt"
cp -R /opt/kata-artifacts/bin/* /opt/kata/bin

mv /opt/kata/bin/qemu /opt/kata/share/

chmod +x /opt/kata/bin/*

cp /opt/kata-artifacts/configuration.toml /usr/share/defaults/kata-containers/configuration.toml
sed -i 's!/usr.*kata-containers/!/opt/kata/bin/!' /usr/share/defaults/kata-containers/configuration.toml

cp /etc/crio/crio.conf /etc/crio/crio.conf.bak

echo "Set Kata containers as default runtime in CRI-O for untrusted workloads"
sed -i '/runtime_untrusted_workload = /c\runtime_untrusted_workload = "/opt/kata/bin/kata-runtime"' /etc/crio/crio.conf

echo "Reload systemd services"
systemctl daemon-reload
systemctl restart crio
