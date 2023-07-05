variable "region" {
  default = "us-east-1"
}

variable "account" {
  description = "Aviatrix Access Account Name"
}

variable "account_id" {
  description = "AWS Account ID"
}

variable "vpcs" {
  default = {
    spk1 = {
      cidr_block = "10.0.0.0/24",
      subnets = {
        public = {
          name              = "spk1_pub"
          cidr_block        = "10.0.0.0/26"
          availability_zone = "us-east-1a"
        },
        private = {
          name              = "spk1_priv"
          cidr_block        = "10.0.0.64/26"
          availability_zone = "us-east-1b"
        }
      }
    },
    spk2 = {
      cidr_block = "10.0.1.0/24",
      subnets = {
        public = {
          name              = "spk2_pub"
          cidr_block        = "10.0.1.0/26"
          availability_zone = "us-east-1a"
        },
        private = {
          name              = "spk2_priv"
          cidr_block        = "10.0.1.64/26"
          availability_zone = "us-east-1b"
        }
      }

    }
  }

}


variable "key_name" {
  description = "EC2 Key Pair for the test VMs"
}

variable "global_edge_inside_cidr_blocks" {
  default = "192.168.0.0/16"
}
variable "use1_edge_inside_cidr_blocks" {
  default = "192.168.0.0/24"
}

variable "avx_transit_Public-gateway-and-firewall-mgmt_subnet_rt_id" {
  description = "Lookup Aviatrix Transit VPC subnet with the name: Public-gateway-and-firewall-mgmt, then lookup the route table ID associated with the subnet"
}