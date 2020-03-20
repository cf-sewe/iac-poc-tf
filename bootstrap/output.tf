output "ssh_command" {
  description = "SSH command for logging into the Terraform EC2 instance"
  value       = "ssh -i ~/.ssh/deployer ec2-user@${aws_instance.deployer_terraform.public_dns}"
}