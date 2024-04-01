output "public_ip" {
  description = "public_ip"
  value       = aws_instance.nexus-server.public_ip
}