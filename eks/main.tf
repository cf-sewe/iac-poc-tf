terraform {
    required_version = ">= 0.12.0"
    backend "s3" {
        encrypt = true
        bucket = "terraform-state2-s3"
        dynamodb_table = "terraform-state-lock-dynamodb"
        region = "eu-west-1"
        key = "cf/terraform/terraform.tfstate"
    }
}

provider "aws" {
    region = var.region
    allowed_account_ids = [var.account_id]
    # todo: find better way to trasnfer the role (required with environment separation)
    assume_role {
        role_arn = "arn:aws:iam::${var.account_id}:role/deployer"
        session_name = "terraform"
    }
}

# initialize helm provider here, it will be passed through through the modules
provider "helm" {
    kubernetes {
        #config_path = "${path.root}/kubeconfig_${var.cluster_name}"
        host = data.aws_eks_cluster.cluster.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
        token = data.aws_eks_cluster_auth.cluster.token
        load_config_file = false
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

# helm: cluster-autoscaler
module "cluster_autoscaler" {
    source = "./modules/helm_cluster_autoscaler"
    account_id = var.account_id
    region = var.region
    cluster_name = var.cluster_name
    eks = module.eks
}

# helm: nginx-ingress
module "nginx_ingress" {
    source = "./modules/helm_nginx_ingress"
    environment = var.environment
    domain = var.domain
    cluster_name = var.cluster_name
    eks = module.eks
}

# helm: grafana
module "grafana" {
    source = "./modules/helm_grafana"
    environment = var.environment
    domain = var.domain
    cluster_name = var.cluster_name
    eks = module.eks
}