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
version=$(yq '.image-version' "$recipe_file")
output_image_path="${BUILD_PREFIX}${name}:${version}"

echo "output_image_path: $output_image_path"

# Get current base digest and base name from our built image
current_labels=$(skopeo inspect "docker://${output_image_path}")
current_base_digest=$(echo "$current_labels" | jq -r '.Labels["org.opencontainers.image.base.digest"]')
base_name=$(echo "$current_labels" | jq -r '.Labels["org.opencontainers.image.base.name"]')

# Get upstream digest from the actual upstream image
upstream_digest=$(skopeo inspect "docker://${base_name}" | jq -r '.Digest')

echo "Current base digest: $current_base_digest"
echo "Upstream base digest: $upstream_digest"

# Compare digests
if [[ "$current_base_digest" == "$upstream_digest" ]]; then
    echo "Base digest matches upstream. No rebuild needed."
    exit 0
else
    echo "Base digest does not match upstream. Rebuild needed."
    exit 1
fi
