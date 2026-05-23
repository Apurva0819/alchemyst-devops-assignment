resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.public_ip
  iam_instance_profile        = var.instance_profile

  user_data = var.user_data 

  root_block_device {
    volume_size = 16
    volume_type = "gp3"
  }

  tags = {
    Name = var.name
  }
}