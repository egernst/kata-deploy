#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

export AZURE_HTTP_USER_AGENT="GITHUBACTIONS_${GITHUB_ACTION_NAME}_${GITHUB_REPOSITORY}"

die() {
        msg="$*"
        echo "ERROR: $msg" >&2
        exit 1
}

[[ -z "$AZ_APPID" ]] && die "no Azure service principal ID provided"
[[ -z "$AZ_PASSWORD" ]] && die "no Azure service principal secret provided"
[[ -z "$AZ_SUBSCRIPTION_ID" ]] && die "no Azure subscription ID provided"
[[ -z "$AZ_TENANT_ID" ]] && die "no Azure tenant ID provided"

# check cluster config existence
# TODO

# Give it a try
LOCATION=${LOCATION:-westus2}
DNS_PREFIX=${DNS_PREFIX:-kata-deploy-${GITHUB_SHA:0:10}}
CLUSTER_CONFIG=${CLUSTER_CONFIG:-/kubernetes-containerd.json}

aks-engine deploy --subscription-id $AZ_SUBSCRIPTION_ID \
	--client-id $AZ_APPID --client-secret $AZ_PASSWORD \
	--location $LOCATION --dns-prefix $DNS_PREFIX \
	--api-model $CLUSTER_CONFIG --force-overwrite

export KUBECONFIG="_output/kubeconfig/kubeconfig.$LOCATION.json"

#kubectl all the things
kubectl get pods --all-namespaces

YAMLPATH="https://raw.githubusercontent.com/egernst/kata-deploy/$GITHUB_SHA/kata-deploy/"
kubectl apply -f "$YAMLPATH/examples/kata-rbac.yaml"
kubectl apply -f "$YAMLPATH/examples/kata-runtimeClass.yaml"

sleep 5

kubectl get runtimeclasses

wget  "$YAMLPATH/kata-deploy.yaml"
wget  "$YAMLPATH/kata-cleanup.yaml"

# update deployment daemonset to utilize the container under test:
sed -i 's:katadocker/kata-deploy:katadocker/kata-deploy-ci:${GITHUB_SHA}:' kata-deploy.yaml
sed -i 's:katadocker/kata-deploy:katadocker/kata-deploy-ci:${GITHUB_SHA}:' kata-cleanup.yaml

# deploy kata:
kubectl apply -f kata-deploy.yaml

## TODO: exercise the runtime

# remove kata (yeah, we are about to destroy, but good to test this flow as well):
kubectl apply -f kata-cleanup.yaml

#cleanup
az login --service-principal -u $AZ_APPID -p $AZ_PASSWORD --tenant $AZ_TENANT_ID
az group delete --name $DNS_PREFIX --yes
az logout
