output "api_public_ip" {
  value = aws_eip.api.public_ip
}

output "engine_private_ip" {
  value = module.engine_vm.private_ip
}

output "math_private_ip" {
  value = module.math_vm.private_ip
}

output "state_private_ip" {
  value = module.state_vm.private_ip
}