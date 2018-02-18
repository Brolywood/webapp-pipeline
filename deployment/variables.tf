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

variable "aws_availability_zone" {
  default = "us-east-1a"
}

variable "aws_ami" {
  default = "ami-97785bed"
}

variable "instance_type" {
  default     = "t2.micro"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "2"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "2"
}

variable "aws_key_name" {
    default = "admin_ssh_key"
}

variable "aws_key_path" {
    default = "./keys/admin_ssh_key.pub"
}

variable "docker_image" {
    default = "webapp/latest"
}
