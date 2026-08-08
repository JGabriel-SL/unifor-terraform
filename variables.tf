variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC e Subnet"
  type        = string
  default     = "192.168.10.0/24"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nome da chave SSH"
  type        = string
  default     = "chave-aula-terraform"
}