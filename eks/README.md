# Kubernetes Cluster - AWS EKS

This Terraform module manages the Kubernetes cluster and its dependencies in the AWS cloud.

# Concept Information

## Permissions
Permissions are received from the Role which is attached to the deployer EC2 instance. Terraform performs "AssumeRole".
This means that no credentials have to be shared. 

## DNS
DNS is managed via Route53. For the PoC a new domain has been registered with Route53 and thus is available directly
as a Hosted Zone.

* Each kubernetes cluster gets its own sub-domain. So for PoC the domain is `*.poc.cplace.xyz` and a cplace instance would
be exposed for example under `demo.poc.cplace.xyz`.
* A wildcard DNS entry is added, so all services in the cluster can directly be accessed without separate DNS entry. 

## TLS Certificate

The certificate for HTTPS communication is 
* generated via Amazon Certificate Manager (ACM)
    * Certificate Renewal works out of the box with ACM
* a Wildcard certificate (`*.<env>.<domain>`) 
* assigned to the Amazon Classic ELB, which terminates the TLS traffic and forwards it it NGINX ingress controller

## Ingress Controller

* for PoC we are still using nginx-ingress controller
* we are using Classic ELB which is automatically provisioned by the nginx-ingress helm chart

## Amazon EKS

* EKS is a managed Kuberenetes Service. 
* For PoC manually managed worker groups are used instead of Amazon Node Groups.
    * It should be clarified if the benefits of Node Groups overweight the Vendor Lock-in disadvantage.
* For EKS setup a Terraform Module is used, which puts a further abstraction layer on top of the AWS Terraform Provider
* All nodes are placed in private Subnet

## AutoScaler
* the cluster is scaled via cluster-autoscaler
* scaler is deployed via Helm
* permissions are granted using [IRSA](https://aws.amazon.com/de/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/)
which ensures that the neccessary permissions are not widely distributed.

# Installation

## Prerequisites

- ensure Bootstrap has been executed successfully, to have an EC2 instance with proper role which can be "Assumed"
by terraform
- manually add Route53 "Hosted Zone" for the desired Domain. For the POC we use the `cplace.xyz` domain.

## Steps

- checkout git on deployer EC2 instance (created by bootstrap procedure) 
- create configuration file `terraform.tfvars`, e.g.:
    ```
    region = "eu-west-1"
    account_id = "347445206419"
    ```
- run `terraform init`
- run `terraform plan`
- run `terraform apply`

