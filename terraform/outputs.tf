output "instance_id" {
  description = "EC2 instance id."
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Public address. The Elastic IP when one is allocated, otherwise the ephemeral one."
  value       = local.public_ip
}

output "app_url" {
  description = "The app by address, which works before DNS has propagated."
  value       = "http://${local.public_ip}"
}

output "app_domain_url" {
  description = "The app by name. Null when domain_name is unset. Plain HTTP — nothing here issues a certificate yet."
  value       = var.domain_name == null ? null : "http://${var.domain_name}"
}

output "ssm_session" {
  description = "Open a shell without SSH, an open port, or a key pair."
  value       = "aws ssm start-session --region ${var.region} --target ${aws_instance.app.id}"
}

output "ssm_port_forward_redis_ui" {
  description = "Reach a loopback-bound service (here RedisInsight) through the SSM tunnel."
  value = join(" ", [
    "aws ssm start-session --region ${var.region} --target ${aws_instance.app.id}",
    "--document-name AWS-StartPortForwardingSession",
    "--parameters '{\"portNumber\":[\"5540\"],\"localPortNumber\":[\"5540\"]}'",
  ])
}
