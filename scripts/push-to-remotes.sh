#!/bin/bash

REMOTE_USER="administrator"
REMOTE_IPS=("207.254.52.100" "207.254.52.104")
SUFFIXES=("-2" "-3")
LOCAL_DIR="/Users/administrator/.tart/vms/ensemble-mini-1"
BASE_REMOTE_DIR="/Users/administrator/.tart/vms/ensemble-mini"

# Loop through each remote IP
for i in "${!REMOTE_IPS[@]}"; do
	# Construct the full remote directory path with suffix
	FULL_REMOTE_DIR="${BASE_REMOTE_DIR}${SUFFIXES[$i]}"
	REMOTE_IP=${REMOTE_IPS[$i]}

	echo "Processing $REMOTE_IP..."

	# SSH into the remote machine and rename the existing directory
	ssh "$REMOTE_USER"@"$REMOTE_IP" "mv $FULL_REMOTE_DIR ${FULL_REMOTE_DIR}-old"

	# Check if the SSH command was successful
	if [ $? -eq 0 ]; then
		echo "Directory at ${REMOTE_IPS[$i]} renamed successfully. Starting copy..."
		# Copy the directory from local to remote machine
		scp -r $LOCAL_DIR "$REMOTE_USER"@"$REMOTE_IP":"$FULL_REMOTE_DIR"
		if [ $? -eq 0 ]; then
			echo "Directory copied successfully to ${REMOTE_IPS[$i]}."
		else
			echo "Error copying directory to ${REMOTE_IPS[$i]}."
		fi
	else
		echo "Error renaming directory on ${REMOTE_IPS[$i]}. Copy not started."
	fi
done
