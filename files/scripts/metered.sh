#!/usr/bin/env bash

set -oue pipefail

# List of services to override
SERVICES=(
    "podman-auto-update.service"
    "brew-upgrade.service"
    "brew-update.service"
)

# Create override files for each service
for service in "${SERVICES[@]}"; do
    override_dir="/usr/lib/systemd/system/${service}.d"
    mkdir -p "${override_dir}"
    cat <<'EOF' > "${override_dir}/10-metered.conf"
[Unit]
Wants=network-online.target
After=network-online.target

[Service]
ExecCondition=/bin/bash -c '[[ "$(busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager Metered | cut -c 3-)" == @(2|4) ]]'
EOF
done

