##
# Assign relevant permissions for AWS resource management to the EC2 instance
#   these will be used by terraform with AssumeRole

data "aws_iam_policy_document" "ec2_role" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
        // todo: without this the assume role from EC2 wont work, check for better alternative
        principals {
            type = "AWS"
            identifiers = ["arn:aws:iam::347445206419:role/deployer"]
        }
    }
}

# create IAM role
resource "aws_iam_role" "deployer" {
    name = "deployer"
    description = "Allow AssumeRole for EC2 instance"
    assume_role_policy = data.aws_iam_policy_document.ec2_role.json
}

# Create EC2 Instance Profile which can be assigned to an EC2 instance
resource "aws_iam_instance_profile" "deployer" {
    name = "deployer"
    role = aws_iam_role.deployer.name
}

# attach IAM policy to deployer role which allows EC2 instance to execute specific commands
resource "aws_iam_role_policy" "deployer" {
    name = "deployer"
    role = aws_iam_role.deployer.id
    policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "acm:*",
        "autoscaling:*",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "ec2:*",
        "elasticloadbalancing:*",
        "eks:*",
        "iam:*",
        "route53:*",
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
ROLE
}