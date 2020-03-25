variable "region" {
    description = "The AWS region in which global resources are set up."
    type        = string
    default     = "eu-west-1"
}

// todo: remove default
variable "account_id" {
    description = "AWS Account to operate on (whitelisting)"
    type        = string
    default     = "347445206419"
}

variable "environment" {
    description = "Deployment Environment. This will be used for tagging and part of the domain name."
    type        = string
    default     = "poc"
}

variable "cluster_name" {
    description = "Name of the EKS Cluster."
    type        = string
    default     = "iac-poc-tf"
}

variable "domain" {
    description = "Domain which is configured as hosted zone in Route53"
    type        = string
    default     = "cplace.xyz"
}
