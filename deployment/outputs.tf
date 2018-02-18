output "elb_address" {
    value = "${aws_elb.web-elb.dns_name}"
}

output "webapp_url" {
    value = "http://${aws_elb.web-elb.dns_name}/webappExample/"
}
