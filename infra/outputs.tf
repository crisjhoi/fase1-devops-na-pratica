# Depois que o Terraform aplica, ele me mostra esses valores no terminal.
# Assim eu já pego o endereço da API pronto pra testar no navegador.

output "ip_publico" {
  description = "IP publico da maquina"
  value       = aws_instance.api.public_ip
}

output "dns_publico" {
  description = "DNS publico da maquina"
  value       = aws_instance.api.public_dns
}

output "url_da_api" {
  description = "URL pra abrir a API no navegador"
  value       = "http://${aws_instance.api.public_dns}:${var.app_port}"
}

output "url_health" {
  description = "URL pra checar se a API esta de pe"
  value       = "http://${aws_instance.api.public_dns}:${var.app_port}/health"
}
