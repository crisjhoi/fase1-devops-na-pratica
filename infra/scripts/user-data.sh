#!/bin/bash
# Esse script roda automático quando a máquina EC2 liga pela primeira vez.
# A graça é essa: eu não preciso entrar na máquina e configurar nada na mão,
# ela mesma instala o Node, baixa o código e já deixa a API no ar.

set -e

# atualiza o sistema e instala o git
dnf update -y
dnf install -y git

# instala o Node 20 pelo repositório oficial da NodeSource
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs

# baixa o projeto e instala só as dependências de produção
cd /opt
git clone ${repo_url} app
cd /opt/app
npm ci --omit=dev

# crio um serviço do systemd pra API subir sozinha no boot
# e se por acaso ela cair, o systemd reinicia (Restart=always).
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

# liga o serviço agora e deixa ele habilitado pros próximos boots
systemctl daemon-reload
systemctl enable api-tarefas
systemctl start api-tarefas
