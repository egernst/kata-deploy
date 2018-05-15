FROM busybox

ADD bin/qemu-system-x86_64 /opt/kata/bin/qemu-system-x86_64
ADD qemu-artifacts/bios-256k.bin /opt/kata/qemu/
ADD qemu-artifacts/bios.bin /opt/kata/qemu/
ADD qemu-artifacts/efi-virtio.bin /opt/kata/qemu/
ADD qemu-artifacts/linuxboot.bin /opt/kata/qemu/
ADD qemu-artifacts/linuxboot_dma.bin /opt/kata/qemu/

WORKDIR /opt/kata/
RUN wget https://github.com/kata-containers/runtime/releases/download/0.2.0/vmlinuz.container
RUN wget https://github.com/kata-containers/runtime/releases/download/0.2.0/kata-containers.img

WORKDIR /opt/kata/bin
RUN wget https://github.com/kata-containers/runtime/releases/download/0.2.0/kata-runtime
RUN wget https://github.com/kata-containers/runtime/releases/download/0.2.0/kata-proxy
RUN wget https://github.com/kata-containers/runtime/releases/download/0.2.0/kata-shim

ADD install-kata.sh /install-kata.sh
ADD configuration.toml /opt/kata/
