#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

YAMLPATH="https://raw.githubusercontent.com/egernst/kata-deploy/$GITHUB_SHA/kata-deploy"

function run_test() {
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

function test_kata() {
	#kubectl all the things
	kubectl get pods --all-namespaces

	kubectl apply -f "$YAMLPATH/kata-rbac.yaml"
	kubectl apply -f "$YAMLPATH/examples/runtimeclass_crd.yaml"
	kubectl apply -f "$YAMLPATH/examples/kata-runtimeClass.yaml"

	sleep 5

	kubectl get runtimeclasses

	wget "$YAMLPATH/kata-deploy.yaml"
	wget "$YAMLPATH/kata-cleanup.yaml"

	# update deployment daemonset to utilize the container under test:
	sed -i "s#katadocker/kata-deploy#katadocker/kata-deploy-ci:${GITHUB_SHA}#g" kata-deploy.yaml
	sed -i "s#katadocker/kata-deploy#katadocker/kata-deploy-ci:${GITHUB_SHA}#g" kata-cleanup.yaml

	# deploy kata:
	kubectl apply -f kata-deploy.yaml

	#wait for kata-deploy to be up
	kubectl -n kube-system wait --timeout=5m --for=condition=Ready -l name=kata-deploy pod

	#Do I see this?
	kubectl get pods --all-namespaces --show-labels
	kubectl get node --show-labels

	run_test

	# remove kata (yeah, we are about to destroy, but good to test this flow as well):
	kubectl delete -f kata-deploy.yaml
	kubectl apply -f kata-cleanup.yaml
	kubectl -n kube-system wait --timeout=5m --for=condition=Ready -l name=kubelet-kata-cleanup pod

	kubectl get pods --all-namespaces --show-labels
	kubectl get node --show-labels

	kubectl delete -f kata-cleanup.yaml
}
