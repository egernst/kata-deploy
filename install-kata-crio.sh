#!/bin/sh

## This script assumes that crio is installed on your system
## For more information refer to the documentation in http://cri-o.io/

## move Kata artifacts to /opt
echo "copying kata artifacts from /tmp to /opt"
cp -R /tmp/kata/* /opt/kata/

chmod +x /opt/kata/bin/*

cp /opt/kata/configuration.toml /usr/share/defaults/kata-containers/configuration.toml

crio_config_file="/etc/crio/crio.conf"

cp $crio_config_file $crio_config_file.bak

cp /etc/crio/crio.conf /etc/crio/crio.conf.bak

## Configure CRIO to use Kata:

### Configure CRIO to use Kata:

## Uncomment next line if you'd like to have default trust level for the cluster be "untrusted":
# sed -i 's/default_workload_trust = "trusted"/default_workload_trust = "untrusted"/' "$crio_config_file"

echo "Set Kata containers as default runtime in CRI-O for untrusted workloads"
 sed -i 's/runtime_untrusted_workload = ""/runtime_untrusted_workload = "\/opt\/kata\/bin\/kata-runtime"/' /etc/crio/crio.conf
echo "Reload systemd services"

systemctl daemon-reload
systemctl restart crio

### Restart CRIO:
