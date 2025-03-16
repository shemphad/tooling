# Data source for the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source for the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu22" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Security group allowing SSH from the internet (port 22) using the default VPC
resource "aws_security_group" "ansible_sg" {
  name        = "ansible_security_group"
  description = "Allow SSH inbound traffic on port 22"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ansible-sg"
  }
}

# EC2 instance resource using the Ubuntu 22.04 AMI and the security group
resource "aws_instance" "sonarqube" {
  count                       = var.instance_count
  ami                         = data.aws_ami.ubuntu22.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ansible_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "ansible-node-${count.index + 1}"
  }
}
