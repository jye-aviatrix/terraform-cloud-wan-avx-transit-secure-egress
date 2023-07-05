variable "cidr_block" {
    description = "The IPv4 CIDR block for the VPC."
}

variable "name" {
  description = "Provide VPC name"
}

variable "subnets" {
    description = "Provide subnets infor for the VPC"
}

variable "key_name" {
  description = "EC2 key pair name"
}