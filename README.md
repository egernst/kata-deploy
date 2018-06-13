# kata-deploy

kata-deploy provides a Dockerfile which contains all of the binaries
and artifacts required to run Kata Containers, as well as reference daemonsets which can be utilized to install Kata Containers on a running Kubernetes cluster.

Note, installation via daemonsets will only succesfully install `kata-runtime` on
a node if it is using either containerd or CRI-O CRI-shims.

## Quick start:

### Installing Kata on a running Kubernetes cluster

```
kubectl apply -f kata-rbac.yaml
kubectl apply -f kata-deploy.yaml
```

### Running a sample workload:

Untrusted workloads can node-select based on ```kata-runtime=true```, and will be
run via kata-runtime if they are marked with the appropriate CRIO or containerd
annotation:
```
CRIO:           io.kubernetes.cri-o.TrustedSandbox: "false"
containerd:     io.kubernetes.cri.untrusted-workload: "true"
```

A sample workload for running untrusted on a kata-enabled node:
```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
   annotations:
    io.kubernetes.cri-o.TrustedSandbox: "false"
    io.kubernetes.cri.untrusted-workload: "true"
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    kata-runtime: "true"
```    

To run:
```
kubectl apply -f https://raw.githubusercontent.com/egernst/k8s-testing-scripts/master/nginx-untrusted.yaml
```

The user should see the pod start, can verify that the pod is indeed making use of
Kata Runtime by comparing the container ID observed by:
```
/opt/kata/bin/kata-runtime list
kubectl describe pod nginx-untrusted
```

To remove the test pod:
```
kubectl delete -f https://raw.githubusercontent.com/egernst/k8s-testing-scripts/master/nginx-untrusted.yaml
```

### Removing Kata from the Kubernetes cluster:

```
kubectl delete -f kata-deploy.yaml
kubectl apply -f kata-cleanup.yaml
kubectl delete -f kata-cleanup.yaml
kubectl delete -f kata-rbac.yaml
```

## kata-deploy Details

### Dockerfile

A Dockerfile is created which contains all of the necessary artifacts for running
Kata Containers.

Host artifacts:
* kata-runtime: pulled from Kata github releases page
* kata-proxy: pulled from Kata github releases page
* kata-shim: pulled from Kata github releases page
* qemu-system-x86_64: statically built and included in this repo, based on Kata's QEMU repo
* qemu/* : supporting binaries required for qemu-system-x86_64

Virtual Machine artifacts:
* kata-containers.img: pulled from Kata github releases page
* vmliuz.container: pulled from Kata github releases page

### Daemonsets and RBAC:

A few daemonsets are introduced for kata-deploy, as well as an RBAC to facilitate
being able to apply labels to the nodes.

#### runtime-labeler:

This daemonset will create a label on each node in
the cluster identifying the CRI shim in use. For example,
`container-runtime=crio` or `container-runtime=containerd.`

#### CRI-O and containerd kata installer:

Depending the value of `container-runtime` label on the node, either the CRI-O or
containerd kata installation daemonset will execute. These daemonsets will install
the necessary kata binaries, configuration files and virtual machine artifacts on
the node. Once installed, it will add a node label `kata-runtime=true` and reconfigure
either CRI-O or containerd to make use of Kata for untrusted workloads.  As a final step it will restart either CRI-O or containerd and kubelet. Upon deletion, the daemonset will remove the kata binaries and VM artifacts and update the node label
to `kata-runtime=cleanup.`

### CRI-O and containerd cleanup:
Depending on the value of `container-runtime`, either the CRI-O or conatinerd Kata cleanup daemonset will run if the node has label `kata-runtime=cleanup.` This daemonsets will remove the `container-runtime` and `kata-runtime` labels as well
as restart either CRI-O or containerd systemctl daemon as well as kubelet. These resets cannot be executed during the preStopHook of the Kata installer daemonset,
which necessitated this final cleanup daemonset.
