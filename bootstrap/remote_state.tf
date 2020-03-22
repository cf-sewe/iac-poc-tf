# add a S3 and DynamoDB which will be used to store remote state

# the bucket name must be unique on all accounts
resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-state2-s3"
    region = var.region
    acl = "private"
    versioning {
        enabled = true
    }
    lifecycle {
        prevent_destroy = false
    }
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
    tags = {
        Name = "S3 Remote Terraform State Store"
    }
}

resource "aws_dynamodb_table" "terraform_lock" {
    name = "terraform-state-lock-dynamodb"
    hash_key = "LockID"
    read_capacity = 20
    write_capacity = 20
    attribute {
        name = "LockID"
        type = "S"
    }
    tags = {
        Name = "DynamoDB Terraform State Lock Table"
    }
}