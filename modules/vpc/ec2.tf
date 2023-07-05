module "aws-linux-vm-public" {
  source    = "jye-aviatrix/aws-linux-vm-public/aws"
  version   = "2.0.2"
  key_name  = var.key_name
  vm_name   = "${var.name}-pub-vm"
  vpc_id    = aws_vpc.this.id
  subnet_id = aws_subnet.this["public"].id
  use_eip = true
}

output "public_vm" {
    value = module.aws-linux-vm-public
}

module "aws-linux-vm-private" {
  source  = "jye-aviatrix/aws-linux-vm-private/aws"
  version = "2.0.1"
  key_name  = var.key_name
  vm_name   = "${var.name}-priv-vm"
  vpc_id    = aws_vpc.this.id
  subnet_id = aws_subnet.this["private"].id
}

output "private_vm" {
  value = module.aws-linux-vm-private
}