# Kubernetes Cluster - AWS EKS

This Terraform module manages the Kubernetes cluster on the AWS cloud.

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