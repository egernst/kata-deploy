FROM centos/systemd
ARG CONTAINERD_VERSION="1.1.0"
ARG CRIO_PPA_URL="https://launchpad.net/~projectatomic/+archive/ubuntu/ppa/+build/14866832/+files"
ARG CRIO_PKG="cri-o-1.10_1.10.1-1~ubuntu16.04.2~ppa28_amd64.deb"
RUN yum install -y \
   dpkg \
   wget

WORKDIR /tmp/crio

https://launchpad.net/~projectatomic/+archive/ubuntu/ppa/+build/14866832/+files/cri-o-1.10_1.10.1-1~ubuntu16.04.2~ppa28_amd64.deb

RUN dpkg -x ${CRIO_PKG}

COPY install-crio.sh /
