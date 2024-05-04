#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)
VARS_FILE="$HOME/Documents/variables.json"

# make sure variables file is in place
if [[ ! -f "$VARS_FILE" ]]; then
	echo 'The Variables file is not in $HOME/Documents'
	exit 1
fi

# make sure needed Xcode xip versions are in place in ~/XcodesCache

packer build \
	-var-file="$VARS_FILE" \
	"$REPO_ROOT/templates/xcode.pkr.hcl"
