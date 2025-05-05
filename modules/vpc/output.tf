output "vpc_name" {
  value = var.vpc_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "Environment" {
  value = var.env
}

output "sg" {
  value = aws_security_group.sg.id
}

output "public-subnet" {
  value = "${aws_subnet.public-subnets.0.id}"
}

output "private-subnet" {
  value = "${aws_subnet.private-subnets.0.id}"
}

output "public_subnet_id" {
  value = "${aws_subnet.public-subnets.*.id}"
}