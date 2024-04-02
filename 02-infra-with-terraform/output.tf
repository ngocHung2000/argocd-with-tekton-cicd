output "public_ip" {
  description = "public_ip"
  value       = aws_instance.microk8s-server.public_ip
}