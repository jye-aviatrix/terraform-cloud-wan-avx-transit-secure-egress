module "mc-transit" {
  source                 = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version                = "2.5.1"
  cloud                  = "AWS"
  region                 = var.region
  cidr                   = "10.16.0.0/23"
  account                = var.account
  local_as_number        = 65001
  enable_transit_firenet = true
  bgp_ecmp = true
  bgp_manual_spoke_advertise_cidrs = "0.0.0.0/0"
}

module "mc-firenet" {
  source         = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version        = "1.5.0"
  transit_module = module.mc-transit
  firewall_image = "aviatrix"
  egress_enabled = true
}



module "vpc" {
  for_each   = var.vpcs
  source     = "./modules/vpc"
  name       = each.key
  cidr_block = each.value.cidr_block
  subnets    = each.value.subnets
  key_name   = var.key_name
}


