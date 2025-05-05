output "public_ips" {
  value = aws_instance.public-server[*].public_ip
}