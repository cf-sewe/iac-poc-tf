variable "region" {
    description = "The AWS region in which global resources are set up."
    default     = "eu-west-1"
}

// todo: remove default
variable "account_id" {
    description = "AWS Account to operate on (whitelisting)"
    default     = "347445206419"
}

variable "cluster_name" {
    description = "Name of the EKS Cluster."
    default     = "iac-poc-tf"
}