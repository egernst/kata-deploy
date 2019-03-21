#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

export AZURE_HTTP_USER_AGENT="GITHUBACTIONS_${GITHUB_ACTION_NAME}_${GITHUB_REPOSITORY}"

YAMLPATH="https://raw.githubusercontent.com/egernst/kata-deploy/$GITHUB_SHA/kata-deploy"
LOCATION=${LOCATION:-westus2}
DNS_PREFIX=${DNS_PREFIX:-kata-deploy-${GITHUB_SHA:0:10}}
CLUSTER_CONFIG=${CLUSTER_CONFIG:-/kubernetes-containerd.json}

test-kata() {
        echo "verify connectivity with a pod using Kata"

        deployment="nginx-deployment"
        busybox_pod="test-nginx"
        busybox_image="busybox"
        cmd="kubectl get pods -a | grep $busybox_pod | grep Completed"
        wait_time=30
        sleep_time=3

        # start the kata pod:
        kubectl apply -f "$YAMLPATH/examples/${deployment}.yaml"
        kubectl wait --for=condition=Available deployment/${deployment}
        kubectl expose deployment/${deployment}

        # test pod connectivity:
        kubectl run $busybox_pod --restart=Never --image="$busybox_image" \
                -- wget --timeout=5 "$deployment"
        waitForProcess "$wait_time" "$sleep_time" "$cmd"
        kubectl logs "$busybox_pod" | grep "index.html"
        kubectl describe pod "$busybox_pod"

        kubectl delete deployment "$deployment"
        kubectl delete service "$deployment"
        kubectl delete pod "$busybox_pod"
}

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

aks-engine deploy --subscription-id $AZ_SUBSCRIPTION_ID \
        --client-id $AZ_APPID --client-secret $AZ_PASSWORD \
        --location $LOCATION --dns-prefix $DNS_PREFIX \
        --api-model $CLUSTER_CONFIG --force-overwrite

export KUBECONFIG="_output/kubeconfig/kubeconfig.$LOCATION.json"

#kubectl all the things
kubectl get pods --all-namespaces

kubectl apply -f "$YAMLPATH/kata-rbac.yaml"
kubectl apply -f "$YAMLPATH/examples/runtimeclass_crd.yaml"
kubectl apply -f "$YAMLPATH/examples/kata-runtimeClass.yaml"

sleep 5

kubectl get runtimeclasses

wget  "$YAMLPATH/kata-deploy.yaml"
wget  "$YAMLPATH/kata-cleanup.yaml"

# update deployment daemonset to utilize the container under test:
sed -i 's#katadocker/kata-deploy#katadocker/kata-deploy-ci:${GITHUB_SHA}#g' kata-deploy.yaml
sed -i 's#katadocker/kata-deploy#katadocker/kata-deploy-ci:${GITHUB_SHA}#g' kata-cleanup.yaml

# deploy kata:
kubectl apply -f kata-deploy.yaml

#wait for kata-deploy to be up
kubectl  wait --for=condition=Available daemonset/kata-deploy

test-kata

# remove kata (yeah, we are about to destroy, but good to test this flow as well):
kubectl apply -f kata-cleanup.yaml

#cleanup
az login --service-principal -u $AZ_APPID -p $AZ_PASSWORD --tenant $AZ_TENANT_ID
az group delete --name $DNS_PREFIX --yes --no-wait
az logout
