variable "name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_ids" {
  type = list(string)
}
variable "public_ip" {}
variable "user_data" {}
variable "instance_profile" {}