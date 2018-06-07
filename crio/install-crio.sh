#!/bin/sh

## Move CRIO artifacts
cp -R /tmp/crio

## Configure Kubelet to use CRIO
echo "Set CRIO as default to be used by K8S"


## Update admin.conf, if it exists

## restart CRIO, Kubelet
systemctl daemon-reload
systemctl enable crio
systemctl start crio
systemctl restart kubelet
