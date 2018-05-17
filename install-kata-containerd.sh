#!/bin/bash

## move Kata artifacts to /opt
mv /tmp/kata /opt/kata

## Configure containerd to use Kata:
sudo mkdir -p /etc/containerd/

cat << EOT | sudo tee /etc/containerd/config.toml
[plugins]
    [plugins.cri.containerd]
      snapshotter = "overlayfs"
      [plugins.cri.containerd.default_runtime]
        runtime_type = "io.containerd.runtime.v1.linux"
        runtime_engine = ""
        runtime_root = ""
      [plugins.cri.containerd.untrusted_workload_runtime]
        runtime_type = "io.containerd.runtime.v1.linux"
        runtime_engine = "/opt/kata/bin/kata-runtime"
        runtime_root = ""
EOT


echo "Reload systemd services"
sudo systemctl daemon-reload
sudo systemctl restart containerd
