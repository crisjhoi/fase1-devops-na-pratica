# Essas são as "configurações" da infra. Deixei tudo como variável pra não
# ter nada chumbado no código e conseguir mudar sem mexer no main.tf.

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
  description = "Tamanho da maquina EC2 (no Academy o t3.micro ja resolve)"
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
  default     = "https://github.com/SEU-USUARIO/fase1-devops-na-pratica.git"
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
  description = "Faixa de IP liberada pra SSH. O ideal e colocar so o meu IP/32."
  type        = string
  default     = "0.0.0.0/0"
}
