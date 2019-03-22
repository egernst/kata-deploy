#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

die() {
	msg="$*"
	echo "ERROR: $msg" >&2
	exit 1
}

source ./setup-aks.sh
source ./test-kata.sh

trap destroy_aks EXIT

setup_aks

test_kata
