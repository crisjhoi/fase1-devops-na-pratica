# variáveis da infra (nada chumbado no main.tf)

variable "aws_region" {
  description = "Regiao da AWS onde a infra vai subir"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto, usado pra nomear os recursos"
  type        = string
  default     = "fase1-devops"
}

variable "instance_type" {
  description = "Tipo da maquina EC2 (t3.micro no Academy)"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Porta em que a API vai rodar"
  type        = number
  default     = 3000
}

variable "repo_url" {
  description = "URL do repositorio Git que a maquina vai clonar pra rodar a API"
  type        = string
  default     = "https://github.com/crisjhoi/fase1-devops-na-pratica.git"
}

variable "key_name" {
  description = "Nome do par de chaves SSH (opcional). Vazio = sem chave."
  type        = string
  default     = ""
}

variable "instance_profile" {
  description = "Perfil IAM da instancia. No AWS Academy costuma ser LabInstanceProfile."
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "Faixa de IP liberada pra SSH (ideal restringir a um /32)"
  type        = string
  default     = "0.0.0.0/0"
}
