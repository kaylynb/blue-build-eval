#!/bin/bash

# Script to check if current base digest matches upstream digest
# Returns 0 if they match, 1 if they don't match

set -euo pipefail

# Configuration
BUILD_PREFIX="ghcr.io/kaylynb/"

# Get recipe file
recipe_file="recipes/$1"

# Get output image path (our built image)
name=$(yq '.name' "$recipe_file")
output_image_path="${BUILD_PREFIX}${name}"

# Get current base digest and base name from our built image
current_labels=$(skopeo inspect "docker://${output_image_path}")
current_base_digest=$(echo "$current_labels" | jq -r '.Labels["org.opencontainers.image.base.digest"]')
base_name=$(echo "$current_labels" | jq -r '.Labels["org.opencontainers.image.base.name"]')

# Get upstream digest from the actual upstream image
upstream_digest=$(skopeo inspect "docker://${base_name}" | jq -r '.Digest')

# Compare digests
if [[ "$current_base_digest" == "$upstream_digest" ]]; then
    echo "0"
else
    echo "1"
fi
