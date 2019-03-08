#!/bin/bash

set -e
export AZURE_HTTP_USER_AGENT="GITHUBACTIONS_${GITHUB_ACTION_NAME}_${GITHUB_REPOSITORY}"

die() {
	echo $1
	exit
}

[[ -z "$AZ_APPID" ]] && die "no Azure service principal ID provided"
[[ -z "$AZ_PASS" ]] && die "no Azure service principal secret provided"
[[ -z "$SUBSCRIPTION_ID" ]] && die "no Azure subscription ID provided"

# check cluster config existence
# TODO

# Give it a try
LOCATION=${LOCATION:-westus2}
DNS_PREFIX=${DNS_PREFIX:-kata-deploy-$GITHUB_REF-$GITHUB_SHA}

aks-engine deploy --subscription-id $SUBSCRIPTION_ID \
	--client-id $AKS_APPID --client-secret $AKS_PW \
	--location $LOCATION --dns-prefix $DNS_PREFIX \
	--api-model $CLUSTER_CONFIG --force-overwrite

if [ -z "$KUBECONFIG" ]; then
	export KUBECONFIG="_output/kubeconfig/kubeconfig.$LOCATION.json"
fi

#kubectl all the things
