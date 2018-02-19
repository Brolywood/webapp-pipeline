provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_s3_bucket" "terraform-states" {
  bucket = "${var.s3prefix}-terraform-states-${var.aws_region}"
  acl = "private"

  # This is good for just in case the file gets corrupted or something bad.
  versioning {
    enabled = true
  }

  tags {
    Name = "terraform-states-${var.aws_region}"
    ManagedBy = "Terraform"
  }
} 

