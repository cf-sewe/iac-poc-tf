terraform {
    required_version = ">= 0.12"
}

# access_key of individual user who runs the bootstrap
provider "aws" {
    region = var.region
    allowed_account_ids = [var.account_id]
    access_key = var.access_key
    secret_key = var.secret_key
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "all" {
    vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = [
        "amazon"]
    filter {
        name = "owner-alias"
        values = ["amazon"]
    }
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "root-device-type"
        values = ["ebs"]
    }
}

# generate SSH key (EC2 only supports RSA keys with default mechanism)
resource "tls_private_key" "deployer" {
    algorithm = "RSA"
    rsa_bits  = "2048"
    provisioner "local-exec" {
        command     = "echo \"${tls_private_key.deployer.private_key_pem}\" > ~/.ssh/deployer_key"
        interpreter = ["/bin/sh", "-c"]
    }
    provisioner "local-exec" {
        command     = "echo \"${tls_private_key.deployer.public_key_pem}\" > ~/.ssh/deployer_key.pub"
        interpreter = ["/bin/sh", "-c"]
    }
    provisioner "local-exec" {
        command     = "chmod 600 ~/.ssh/deployer_key"
        interpreter = ["/bin/sh", "-c"]
    }
}

# assign SSH key for AWS
resource "aws_key_pair" "deployer" {
    key_name   = "deployer"
    public_key = tls_private_key.deployer.public_key_openssh
}

resource "aws_instance" "deployer_terraform" {
    key_name = aws_key_pair.deployer.key_name
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
    subnet_id = tolist(data.aws_subnet_ids.all.ids)[0]
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.deployer.name
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
        from_port = 8
        # ICMP type
        to_port = 0
        # ICMP code
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

# Provision the deployer using remote-exec
# Note: Provisioners only execute once, as they are intended for bootstrapping only:
#       https://stackoverflow.com/questions/39069311/terraform-how-to-run-remote-exec-more-than-once
resource "null_resource" "deployer_bootstrap" {
    triggers = {
        public_ip = aws_instance.deployer_terraform.public_ip
    }
    connection {
        type  = "ssh"
        host  = aws_instance.deployer_terraform.public_ip
        user  = "ec2-user"
        private_key = tls_private_key.deployer.private_key_pem
        port  = 22
        agent = false
    }
    // copy our example script to the server
    #provisioner "file" {
    #    source      = "scripts/bootstrap.sh"
    #    destination = "/tmp/bootstrap.sh"
    #}
    // change permissions to executable and pipe its output into a new file
    provisioner "remote-exec" {
        inline = [
            "set -e",
            "sudo yum -q -y install unzip git",
            "if [ ! -e /usr/local/bin/terraform ]; then",
            "  curl -s -O https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip",
            "  sudo unzip terraform_0.12.24_linux_amd64.zip -d /usr/local/bin/",
            "fi",
            "rm terraform_0.12.24_linux_amd64.zip",
            "sudo curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash",
            "sudo wget -q -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.17.4/bin/linux/amd64/kubectl",
            "sudo chmod +x /usr/local/bin/kubectl"
        ]
    }
    #provisioner "local-exec" {
    #    # copy the public-ip file back to CWD, which will be tested
    #    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${aws_instance.example_public.public_ip}:/tmp/public-ip public-ip"
    #    command = "sftp -oStrictHostKeyChecking=no -i ${var.cluster_name}_key ubuntu@${aws_instance.blueharvest-terraform-eks-openvpn.public_ip}:client-configs/files/${var.cluster_name}.ovpn ./"
    #}
}