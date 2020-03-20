terraform {
  required_version = ">= 0.12"
}

# access key of user who runs the bootstrap
provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  #shared_credentials_file = "/Users/tf_user/.aws/creds"
  #profile                 = "customprofile"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# manually generated SSH key (EC2 only supports RSA keys)
resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = var.deployer_public_key
}

resource "aws_instance" "deployer_terraform" {
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id = tolist(data.aws_subnet_ids.all.ids)[0]
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  tags = {
    Name = "deployer-terraform"
  }
}

resource "aws_security_group" "allow_ssh" {
  vpc_id = data.aws_vpc.default.id
  name = "deployer-terraform"
  description = "Allow SSH access to EC2 instance"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8 # ICMP type
    to_port = 0   # ICMP code
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow-ssh"
  }
}