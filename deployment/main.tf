provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

terraform {
  backend "s3" {}
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_availability_zone}"
  map_public_ip_on_launch = true
}

resource "aws_elb" "web-elb" {
  name             = "web-elb"
  security_groups  = ["${aws_security_group.default.id}"]
  subnets          = ["${aws_subnet.default.id}"]
    
  listener {
    lb_port             = 80
    lb_protocol         = "HTTP"
    instance_port       = 8080
    instance_protocol   = "HTTP"
  }
}

resource "aws_autoscaling_group" "web-asg" {
  lifecycle { create_before_destroy = true }

  name                 = "web-asg - ${aws_launch_configuration.web-lc.name}"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  min_elb_capacity     = "${var.asg_desired}"
  wait_for_capacity_timeout = "15m"
  launch_configuration = "${aws_launch_configuration.web-lc.name}"
  load_balancers       = ["${aws_elb.web-elb.name}"]
  vpc_zone_identifier  = ["${aws_subnet.default.id}"]

  tag = [
    {
      key                 = "Name"
      value               = "webapp-server"
      propagate_at_launch = "true"
    },
    {
      key                 = "Image"
      value               = "${var.docker_image}"
      propagate_at_launch = "true"
    }
  ]
  
}

data "template_file" "webapp_install" {
  template = "${file("webapp_install.tpl")}"

  vars {
    docker_image = "${var.docker_image}"
  }
}

resource "aws_launch_configuration" "web-lc" {
  lifecycle { create_before_destroy = true }

  image_id      = "${var.aws_ami}"
  instance_type = "${var.instance_type}"

  security_groups = ["${aws_security_group.default.id}"]

  user_data       = "${data.template_file.webapp_install.rendered}"
  key_name        = "${aws_key_pair.auth.id}"
}

resource "aws_security_group" "default" {
  name          = "terraform_example_sg"
  vpc_id        = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_key_name}"
  public_key = "${file(var.aws_key_path)}"
}
