#!/bin/bash

set -eux

apt-get update -y

apt-get install -y \
    curl \
    git \
    unzip \
    python3 \
    python3-pip \
    nodejs \
    npm

curl -fsSL https://bun.sh/install | bash

export BUN_INSTALL="/root/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

curl -fsSL https://install.iii.dev/iii/main/install.sh | sh

mkdir -p /opt/iii

cat <<EOF >/opt/iii/config.yaml
server:
  host: 0.0.0.0
  port: 49134
EOF

cat <<EOF >/etc/systemd/system/iii-engine.service
[Unit]
Description=iii Engine
After=network.target

[Service]
Type=simple
ExecStart=/root/.local/bin/iii server start --config /opt/iii/config.yaml
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable iii-engine
systemctl start iii-engine