# Bootstrap Procedure

The bootstrap procedure will install and configure Terraform (TF) in the AWS cloud on an EC2 instance.  
A policy with `AssumeRole` permission will be applied to the EC2 instance, which TF can use to run the desired automation
task inside the AWS cloud.  
Bootstrapping is performed from user device via user credentials. 

Steps:

- create "automation" EC2 instance in default VPC
- create SecurityGroup to allow SSH access from internet
- create Policy to allow AssumeRole and attach to the EC2 instance
- run bootstrap.sh script which installs Terraform to EC2 instance
- configure Terraform to use the EC2 Instance AssumeRole capability

Notes:

- when the ami version updates, the EC2 instance will be recreated -> the EC2 instance must be designed ephemeral

# Running the Bootstrap Procedure

## Preparation
- create IAM user 'terraform' in AWS console
- assign permission policies:
   - AmazonEC2FullAccess
   - IAMFullAccess
- get terraform access key and add to `terraform.tfvars`
- install terraform on local computer

## Execution
- run `terraform init`
- run `terraform plan`
- run `terraform apply`

# Open Topics

For the final, production ready implementation at least the following issues have to be addressed:

- refactor TF code to individual modules
- consider saving bootstrap `terraform.tfstate` to S3, else the bootstrap state is only locally available
- Deploy automation EC2 instance in separate (environment independent) AWS Account
- Have TF deploy to various environments, each in their own AWS account via AssumeRole