resource "aws_kms_key" "a" {
  description = "KMS key 1"
}

variable "s3_id" {
  type    = string
  default = "first_name"

}

resource "random_pet" "s3" {
  keepers = {
    # Generate a new pet name each time we switch to a new bucket
    s3 = var.s3_id
  }
}

resource "aws_s3_bucket" "b" {
  bucket = random_pet.s3.id
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.a.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

output "s3" {
  value = aws_s3_bucket.b.*
}

