variable "environment" {
    description = "Deployment Environment. This will be used for tagging and part of the domain name."
    type = string
}

variable "cluster_name" {
    description = "Name of the EKS Cluster."
    type = string
}

variable "domain" {
    description = "Domain which is configured as hosted zone in Route53"
    type = string
}

# not used, but used to define dependency
variable "eks" {
    description = "EKS Output information"
}

variable "azuread_client_id" {
    description = "Client ID for AzureAD authentication (used e.g. by Grafana)"
    type = string
}

variable "azuread_client_secret" {
    description = "Client Secret for AzureAD authentication (used e.g. by Grafana)"
    type = string
}