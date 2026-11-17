# Aqui é o "coração" da infraestrutura: é o que vai subir a máquina na AWS
# pra hospedar a API. Escrevi pensando no ambiente do AWS Academy (Learner Lab).

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# provedor = AWS. A região vem de uma variável (no Academy costuma ser us-east-1).
provider "aws" {
  region = var.aws_region
}

# Em vez de criar uma VPC do zero, uso a VPC padrão que a conta já tem.
# No Learner Lab isso facilita bastante e evita erro de permissão.
data "aws_vpc" "default" {
  default = true
}

# Pego a imagem mais recente do Amazon Linux 2023 (assim não chumbo um ID de AMI,
# que muda de região pra região e fica velho com o tempo).
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Grupo de segurança = o "firewall" da máquina.
# Libero a porta da aplicação e a 22 (SSH) pra eu conseguir acessar se precisar.
resource "aws_security_group" "api" {
  name        = "${var.project_name}-sg"
  description = "Libera as portas que a API precisa"
  vpc_id      = data.aws_vpc.default.id

  # porta da API (onde o Node vai escutar)
  ingress {
    description = "Acesso HTTP a API"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH pra eu entrar na máquina se eu precisar depurar algo.
  # OBS pra mim: em produção de verdade eu restringiria isso só pro meu IP.
  ingress {
    description = "Acesso SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # saída liberada pra tudo (a máquina precisa baixar o node, as libs, etc.)
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

# A máquina em si (EC2). Quando ela liga, roda o script de user-data,
# que instala o Node e deixa a API no ar sozinha.
resource "aws_instance" "api" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.api.id]
  key_name               = var.key_name != "" ? var.key_name : null

  # no AWS Academy a gente precisa usar o perfil "LabInstanceProfile".
  # deixei como variável: se vier vazio, o Terraform ignora.
  iam_instance_profile = var.instance_profile != "" ? var.instance_profile : null

  # esse templatefile injeta a URL do repositório e a porta dentro do script
  user_data = templatefile("${path.module}/scripts/user-data.sh", {
    repo_url = var.repo_url
    app_port = var.app_port
  })

  tags = {
    Name    = "${var.project_name}-api"
    Projeto = var.project_name
  }
}
