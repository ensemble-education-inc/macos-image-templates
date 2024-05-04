#!/bin/bash

# Run this script from the root of the repo

source_dir="./tartelet-scripts"
destination_dir="$HOME/.tartelet"

if [ ! -d "$destination_dir" ]; then
	mkdir -p "$destination_dir"
fi

for file in "$source_dir"/*; do
	if [ -f "$file" ]; then
		filename=$(basename "$file")
		ln "$file" "$destination_dir/$filename"
		echo "Hard link created for '$filename'"
	fi
done

echo "Hard linking completed."
