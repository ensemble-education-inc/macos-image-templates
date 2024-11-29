#!/bin/bash

# This script will build a new image for our Ensemble runners that the runners can copy and install.

REPO_ROOT=$(git rev-parse --show-toplevel)
VARS_FILE="$REPO_ROOT/scripts/variables.json"

tart pull "ghcr.io/cirruslabs/macos-sonoma-base:latest"

packer init "$REPO_ROOT/templates/ensemble.pkr.hcl"

packer build \
	-var-file="$VARS_FILE" \
	"$REPO_ROOT/templates/ensemble.pkr.hcl"
