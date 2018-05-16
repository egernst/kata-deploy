# kata-deploy

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

