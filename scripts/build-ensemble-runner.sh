#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)
VARS_FILE="$HOME/Documents/variables.json"

# make sure variables file is in place
if [[ ! -f "$VARS_FILE" ]]; then
	echo 'The Variables file is not in $HOME/Documents'
	exit 1
fi

# make sure needed Xcode xip versions are in place in ~/XcodesCache

tart pull "ghcr.io/cirruslabs/macos-sonoma-base:latest"

packer build \
	-var-file="$VARS_FILE" \
	"$REPO_ROOT/templates/ensemble.pkr.hcl"

# tart export new image

# tart rename old image

# tart rename new image to old image name

# push exported image to other runners

# tart export ensemble-xcode-16 $HOME/Desktop/ensemble-xcode-16
#
# scp $HOME/Desktop/ensemble-xcode-16.tvm administrator@207.254.52.100:/Users/administrator/Desktop/ensemble-xcode-16.tvm
#
# scp $HOME/Desktop/ensemble-xcode-16.tvm administrator@207.254.52.104:/Users/administrator/Desktop/ensemble-xcode-16.tvm
