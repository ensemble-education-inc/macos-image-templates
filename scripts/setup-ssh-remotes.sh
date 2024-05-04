#!/bin/bash

REMOTE_USER="administrator"
REMOTE_IPS=("207.254.52.100" "207.254.52.104")
SSH_KEY="$HOME/.ssh/id_rsa.pub"

if [ ! -f "$SSH_KEY" ]; then
	echo "SSH key not found, generating one..."
	ssh-keygen -t rsa -b 2048 -f "$HOME/.ssh/id_rsa" -N ""
fi

for IP in "${REMOTE_IPS[@]}"; do
	echo "Copying SSH key to $REMOTE_USER@$IP..."
	ssh-copy-id -i "$SSH_KEY" "$REMOTE_USER@$IP"
done

echo "SSH key deployment complete."
