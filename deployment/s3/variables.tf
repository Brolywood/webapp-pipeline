variable "aws_access_key" {
  type        = "string"
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = "string"
  description = "AWS secret key"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "s3prefix" {
  type        = "string"
}
