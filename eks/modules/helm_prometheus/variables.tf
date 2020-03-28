variable "cluster_name" {
    description = "Name of the EKS Cluster."
    type        = string
}

# not used, but used to define dependency
variable "eks" {
    description = "EKS Output information"
}