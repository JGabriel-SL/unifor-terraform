output "comando_ssh" {
  description = "Comando para conectar via SSH"
  value       = [for ip in aws_instance.webserver[*].public_ip : "ssh -i ~/.ssh/id_rsa_aws ubuntu@${ip}"]
}

output "url_servidor" {
  description = "Url para acesso ao Nginx na EC2"
  value       = [for ip in aws_instance.webserver[*].public_ip : "http://${ip}"]
}