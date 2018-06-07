FROM centos/systemd
ARG CONTAINERD_VERSION="1.1.0"
RUN yum install -y wget

# Get  cri-containerd artifacts
WORKDIR /tmp/containerd/
RUN wget https://storage.googleapis.com/cri-containerd-release/cri-containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz

RUN sudo tar -C / -xzf cri-containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz

COPY install-containerd.sh /
