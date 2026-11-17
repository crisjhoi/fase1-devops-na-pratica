#!/bin/bash
# roda quando a EC2 liga: instala o Node, baixa o código e sobe a API sozinha.

set -e

# atualiza o sistema e instala o git
dnf update -y
dnf install -y git

# instala o Node 20 (NodeSource)
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs

# baixa o projeto e instala as dependências de produção
cd /opt
git clone ${repo_url} app
cd /opt/app
npm ci --omit=dev

# serviço systemd pra API subir no boot e reiniciar se cair
cat > /etc/systemd/system/api-tarefas.service <<'UNIT'
[Unit]
Description=API de Tarefas - DevOps na Pratica
After=network.target

[Service]
WorkingDirectory=/opt/app
Environment=PORT=${app_port}
ExecStart=/usr/bin/node src/server.js
Restart=always
User=root

[Install]
WantedBy=multi-user.target
UNIT

# habilita e inicia o serviço
systemctl daemon-reload
systemctl enable api-tarefas
systemctl start api-tarefas
