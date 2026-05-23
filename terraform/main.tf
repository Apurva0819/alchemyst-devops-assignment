data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

module "network" {
  source = "./modules/network"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  az                  = "${var.aws_region}a"
}

module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  vpc_id       = module.network.vpc_id
}

resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ssm_role.name
}

 module "api_vm" {
  source = "./modules/ec2"
  depends_on = [module.engine_vm]
  name               = "api-vm"
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = "t3.micro"
  subnet_id          = module.network.public_subnet_id
  security_group_ids = [module.security_groups.api_sg_id]
  public_ip          = true
  instance_profile   = aws_iam_instance_profile.this.name
  user_data = templatefile("${path.module}/userdata/api.sh", {
  engine_ip = module.engine_vm.private_ip
})
} 

module "engine_vm" {
  source = "./modules/ec2"

  name               = "engine-vm"
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = "t3.micro"
  subnet_id          = module.network.private_subnet_id
  security_group_ids = [module.security_groups.engine_sg_id]
  public_ip          = false
  user_data          = "${path.module}/userdata/engine.sh"
  instance_profile   = aws_iam_instance_profile.this.name
}

module "math_vm" {
  source = "./modules/ec2"
  depends_on = [module.engine_vm]
  name               = "math-vm"
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = "t3.micro"
  subnet_id          = module.network.private_subnet_id
  security_group_ids = [module.security_groups.worker_sg_id]
  public_ip          = false
  instance_profile   = aws_iam_instance_profile.this.name
  user_data = templatefile("${path.module}/userdata/math.sh", {
  engine_ip = module.engine_vm.private_ip
})
}

module "state_vm" {
  source = "./modules/ec2"
  depends_on = [module.engine_vm]
  name               = "state-vm"
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = "t3.micro"
  subnet_id          = module.network.private_subnet_id
  security_group_ids = [module.security_groups.worker_sg_id]
  public_ip          = false
  instance_profile   = aws_iam_instance_profile.this.name
  user_data = templatefile("${path.module}/userdata/state.sh", {
  engine_ip = module.engine_vm.private_ip
})
}
resource "aws_eip" "api" {
  instance = module.api_vm.instance_id
  domain   = "vpc"
}
