data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-aula-terraform"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-aula"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "subnet-publica"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "rota-publica"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "webserver" {
  name        = "sgp-webserver-aula"
  description = "Permitir trafego HTTP na porta 80"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Permite tudo"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgp-webserver-aula"
  }
}

resource "aws_key_pair" "chave_ssh" {
  key_name   = var.key_name
  public_key = file("~/.ssh/id_rsa_aws.pub")
}

resource "aws_instance" "webserver" {
  count = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.webserver.id]
  key_name               = aws_key_pair.chave_ssh.key_name

  tags = {
    Name = "ec2-webserver-aula-terraform"
  }
}

resource "local_file" "hosts_inventory" {
  filename = "hosts.ini"
  
  content = <<-EOT
    [webservers]
    %{ for ip in aws_instance.webserver[*].public_ip ~}
    ${ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa_aws ansible_python_interpreter=/usr/bin/python3
    %{ endfor ~}
  EOT
}

