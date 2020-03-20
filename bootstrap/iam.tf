##
# Assign relevant permissions for AWS resource management to the EC2 instance
#   these will be used by terraform with AssumeRole

# create IAM role
resource "aws_iam_role" "deployer" {
    name = "deployer"
    assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
ROLE
}

# Create EC2 Instance Profile which can be assigned to an EC2 instance
resource "aws_iam_instance_profile" "deployer" {
    name = "deployer"
    role = aws_iam_role.deployer.name
}

# add IAM Policies which allows EC2 instance to execute specific commands
resource "aws_iam_role_policy" "deployer" {
    name = "deployer"
    role = aws_iam_role.deployer.id

    policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
ROLE
}