variable "access_key" {
}

variable "secret_key" {
}

variable "region" {
  description = "The AWS region in which global resources are set up."
  default     = "eu-west-1"
}

variable "deployer_public_key" {
  description = "The public key of the manually generated Deployer SSH Key (ssh-keygen -t rsa -b 2048 -C deployer -f deployer -N \"\" -q)"
  default     = "ssh-ed25519 AAAA... deployer"
}