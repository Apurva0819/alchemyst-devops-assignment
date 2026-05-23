#!/bin/bash

set -eux

apt-get update -y

apt-get install -y \
    git \
    curl \
    nodejs \
    npm \
    python3 \
    python3-pip

curl -fsSL https://bun.sh/install | bash

export BUN_INSTALL="/root/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

curl -fsSL https://install.iii.dev/iii/main/install.sh | sh

mkdir -p /opt/alchemyst

cd /opt/alchemyst

git clone https://github.com/Alchemyst-ai/hiring.git

cd hiring/may-2026/devops/quickstart

npm install

cat <<EOF >/etc/systemd/system/caller-worker.service
[Unit]
Description=Caller Worker
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/alchemyst/hiring/may-2026/devops/quickstart
ExecStart=/usr/bin/npm run caller-worker -- --server ws://ENGINE_PRIVATE_IP:49134
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/systemd/system/http-worker.service
[Unit]
Description=iii HTTP Worker
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/alchemyst/hiring/may-2026/devops/quickstart
ExecStart=/root/.local/bin/iii worker add @iii/http --server ws://${engine_ip}:49134 --port 80
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl enable caller-worker
systemctl enable http-worker

systemctl start caller-worker
systemctl start http-worker