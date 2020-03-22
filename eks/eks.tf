data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

provider "kubernetes" {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token = data.aws_eks_cluster_auth.cluster.token
    load_config_file = false
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    cluster_name = var.cluster_name
    subnets = module.vpc.private_subnets
    vpc_id = module.vpc.vpc_id
    worker_groups = [
        {
            name = "worker-group-1"
            instance_type = "t3.micro"
            additional_userdata = "echo foo bar"
            asg_desired_capacity = 1
            additional_security_group_ids = [
                aws_security_group.worker_group_mgmt_one.id
            ]
        },
        {
            name = "worker-group-2"
            instance_type = "t3.micro"
            additional_userdata = "echo foo bar"
            additional_security_group_ids = [
                aws_security_group.worker_group_mgmt_two.id
            ]
            asg_desired_capacity = 1
        },
    ]
    worker_additional_security_group_ids = [
        aws_security_group.all_worker_mgmt.id
    ]
    #map_roles                            = var.map_roles
    #map_users                            = var.map_users
    #map_accounts                         = var.map_accounts
    tags = {
        Environment = "test"
        GithubRepo = "terraform-aws-eks"
        GithubOrg = "terraform-aws-modules"
    }
}