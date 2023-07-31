provider "aws" {
    region = "us-west-2"
    secret_key = "secret-key"
    access_key = "access_key"
  
}

resource "aws_s3_bucket" "first-bucket" {
  bucket = "my-tf-test-bucket"
  acl    = "private"
  tags = {
    Name : "S3-terraform-demo"
    Environment: "testing"
  }

  versioning {
    enabled = true
  }
}

output "awss3bucket"{
    value = aws_s3_bucket.first-bucket.id
  
}