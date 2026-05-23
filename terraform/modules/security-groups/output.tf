output "api_sg_id" {
  value = aws_security_group.api.id
}

output "engine_sg_id" {
  value = aws_security_group.engine.id
}

output "worker_sg_id" {
  value = aws_security_group.worker.id
}