variable "region" {
    description = "The AWS region in which global resources are set up."
    type        = string
}

variable "account_id" {
    description = "AWS Account to operate on (whitelisting)"
    type        = string
}

variable "cluster_name" {
    description = "Name of the EKS Cluster."
    type        = string
}

variable "eks" {
    description = "EKS Output information"
}
