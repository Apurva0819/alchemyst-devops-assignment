#!/bin/bash

set -eux

apt-get update -y

apt-get install -y \
    git \
    curl \
    python3 \
    python3-pip \
    python3-venv

curl -fsSL https://bun.sh/install | bash

export BUN_INSTALL="/root/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

curl -fsSL https://install.iii.dev/iii/main/install.sh | sh

mkdir -p /opt/alchemyst

cd /opt/alchemyst

git clone https://github.com/Alchemyst-ai/hiring.git

cd hiring/may-2026/devops/quickstart

python3 -m venv venv

source venv/bin/activate

pip install -r requirements.txt

cat <<EOF >/etc/systemd/system/math-worker.service
[Unit]
Description=Math Worker
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/alchemyst/hiring/may-2026/devops/quickstart
ExecStart=/bin/bash -c 'source venv/bin/activate && python workers/math_worker.py --server ws://${engine_ip}:49134'
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl enable math-worker
systemctl start math-worker