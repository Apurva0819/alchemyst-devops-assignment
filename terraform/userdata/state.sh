#!/bin/bash

set -eux

apt-get update -y

apt-get install -y \
    curl \
    git \
    nodejs \
    npm

curl -fsSL https://bun.sh/install | bash

export BUN_INSTALL="/root/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

curl -fsSL https://install.iii.dev/iii/main/install.sh | sh

mkdir -p /opt/alchemyst

cd /opt/alchemyst

git clone https://github.com/Alchemyst-ai/hiring.git

cd hiring/may-2026/devops/quickstart

cat <<EOF >/etc/systemd/system/state-worker.service
[Unit]
Description=iii State Worker
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/alchemyst/hiring/may-2026/devops/quickstart
ExecStart=/root/.local/bin/iii worker add @iii/state --server ws://${engine_ip}:49134
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl enable state-worker
systemctl start state-worker