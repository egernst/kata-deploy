# kata-deploy

This repo containers a few daemonsets via kata-deploy.yaml, Dockerfile for kata-deploy container image
as well as some of the artifacts associated with the docker image.

With this, if a user has an existing Kubernetes cluster, running
```
kubectl apply -f https://raw.githubusercontent.com/egernst/kata-deploy/master/kata-deploy.yaml
```
should result in each node with CRIO or containerd configured to be labeled (either ```container-runtime=cri-o``` or ```container-runtime=containerd```), and for kata-runtime to be installed
and configured through a daemonset for these matching nodes.  The crio or containerd configuration will be updated
to use kata-runtime for untrusted workloads.  nodes which have kata-runtime installed successfully will be marked with the label ```kata-runtime=true```.

Untrusted workloads can node-select based on ```kata-runtime=true```, and will be run via kata-runtime if they are marked with
the appropriate CRIO or containerd annotation:
```
CRIO:           io.kubernetes.cri-o.TrustedSandbox: "false"
containerd:     io.kubernetes.cri.untrusted-workload: "true"
```



## Kata Artifacts to Install:

A Dockerfile is created which containers all of the necessary artifacts for running Kata Containers on a K8S node.

### Host Artififacts:

1. kata-runtime: pulled from Kata github releases page
2. kata-proxy: pulled from Kata github releases page
3. kata-shim: pulled from Kata github releases page
4. qemu-system-x86_64: statically built and included in this repo, based on [Kata's QEMU repo](https://github.com/kata-containers/qemu/tree/qemu-lite-2.11.0)
5. qemu/* : supporting binaries required for qemu-system-x86_64

### Virtual Machine Artifacts:

1. kata-containers.img: pulled from Kata github releases page
2. vmliuz.container: pulled from Kata github releases page

