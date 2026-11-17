# infraestrutura na AWS pra hospedar a API (pensado pro AWS Academy).

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# provedor AWS; região vem de variável
provider "aws" {
  region = var.aws_region
}

# usa a VPC padrão da conta (evita erro de permissão no Learner Lab)
data "aws_vpc" "default" {
  default = true
}

# pega a AMI mais recente do Amazon Linux 2023 (sem chumbar um ID)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# grupo de segurança = firewall da máquina
resource "aws_security_group" "api" {
  name        = "${var.project_name}-sg"
  description = "Libera as portas que a API precisa"
  vpc_id      = data.aws_vpc.default.id

  # porta da API
  ingress {
    description = "Acesso HTTP a API"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH (ideal restringir a faixa num cenário real)
  ingress {
    description = "Acesso SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # saída liberada
  egress {
    description = "Saida liberada"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Projeto = var.project_name
  }
}

# máquina EC2; ao ligar, roda o user-data que sobe a API
resource "aws_instance" "api" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.api.id]
  key_name               = var.key_name != "" ? var.key_name : null

  # perfil IAM (no Academy, LabInstanceProfile); vazio = ignora
  iam_instance_profile = var.instance_profile != "" ? var.instance_profile : null

  # injeta o repo e a porta no script de user-data
  user_data = templatefile("${path.module}/scripts/user-data.sh", {
    repo_url = var.repo_url
    app_port = var.app_port
  })

  tags = {
    Name    = "${var.project_name}-api"
    Projeto = var.project_name
  }
}
