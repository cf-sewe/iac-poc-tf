terraform {
    required_version = ">= 0.12.0"
    backend "s3" {
        encrypt        = true
        bucket         = "terraform-state2-s3"
        dynamodb_table = "terraform-state-lock-dynamodb"
        region         = "eu-west-1"
        key            = "cf/terraform/terraform.tfstate"
    }
}

provider "aws" {
    region = var.region
    allowed_account_ids = [var.account_id]
    # todo: find better way to trasnfer the role (required with environment separation)
    assume_role {
      role_arn     = "arn:aws:iam::${var.account_id}:role/deployer"
      session_name = "terraform"
    }
}

provider "random" {}

provider "local" {}

provider "null" {}

provider "template" {}

resource "aws_security_group" "worker_group_mgmt_one" {
    name_prefix = "worker_group_mgmt_one"
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [
            "10.0.0.0/8",
        ]
    }
}

resource "aws_security_group" "worker_group_mgmt_two" {
    name_prefix = "worker_group_mgmt_two"
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [
            "192.168.0.0/16",
        ]
    }
}

resource "aws_security_group" "all_worker_mgmt" {
    name_prefix = "all_worker_management"
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [
            "10.0.0.0/8",
            "172.16.0.0/12",
            "192.168.0.0/16",
        ]
    }
}