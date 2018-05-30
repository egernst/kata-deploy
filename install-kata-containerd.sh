#!/bin/sh

## This script assumes that containerd is already installed
## To install it you can run the following:
## export CONTAINERD_VERSION=1.1.0
## wget https://storage.googleapis.com/cri-containerd-release/cri-containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz
## sudo tar -C / -xzf cri-containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz

## move Kata artifacts to /opt
echo "copying kata artifacts from /tmp to /opt"
cp -R /tmp/kata/* /opt/kata/
chmod +x /opt/kata/bin/*

cp /opt/kata/configuration.toml /usr/share/defaults/kata-containers/configuration.toml

## Configure containerd to use Kata:
echo "create containerd configuration for Kata"
mkdir -p /etc/containerd/

cat << EOT | tee /etc/containerd/config.toml
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
systemctl daemon-reload
systemctl restart containerd
