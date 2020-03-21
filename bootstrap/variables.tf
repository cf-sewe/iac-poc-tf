variable "access_key" {
}

variable "secret_key" {
}

variable "region" {
  description = "The AWS region in which global resources are set up."
  default     = "eu-west-1"
}

// todo: remove default
variable "account_id" {
    description = "AWS Account to operate on (whitelisting)"
    default     = "347445206419"
}

variable "audit_s3_bucket_name" {
  description = "The name of the S3 bucket to store various audit logs."
}