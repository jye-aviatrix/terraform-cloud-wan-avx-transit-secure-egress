locals {
    avx_transit_vpc_arn="arn:aws:ec2:${var.region}:${var.account_id}:vpc/${module.mc-transit.vpc.vpc_id}"
    avx_transit_vpc_subnet_ids=values({for idx, subnet in module.mc-transit.vpc.subnets : idx => subnet if length(regexall("Public-gateway-and-firewall-mgmt", subnet.name)) > 0 })[*].subnet_id
    avx_transit_vpc_subnet_arns = [for subnet_id in local.avx_transit_vpc_subnet_ids : "arn:aws:ec2:${var.region}:${var.account_id}:subnet/${subnet_id}"]
}

# Attach Aviatrix Transit VPC to Core Network Edge to act as transport for GRE Connect
resource "aws_networkmanager_vpc_attachment" "avx_transit_vpc_attach_to_core" {
  subnet_arns     = local.avx_transit_vpc_subnet_arns
  core_network_id = aws_networkmanager_core_network.this.id
  vpc_arn         = local.avx_transit_vpc_arn
  tags = {
    segment = "default"
  }
}

# Add a Connect attachment between Core Network Edge to Aviatrix Transit via VPC attachment as transport
resource "aws_networkmanager_connect_attachment" "avx_transit_vpc_connect_attachment" {
  core_network_id         = aws_networkmanager_core_network.this.id
  transport_attachment_id = aws_networkmanager_vpc_attachment.avx_transit_vpc_attach_to_core.id
  edge_location           = aws_networkmanager_vpc_attachment.avx_transit_vpc_attach_to_core.edge_location
  options {
    protocol = "GRE"
  }
  tags = {
    segment = "default"
  }
}

# Create connect peers, reference following article for the outside/inside IP schema between Aviatrix Transit and Edge
# https://github.com/jye-aviatrix/terraform-aviatrix-bgp-over-gre-brownfield-tgw-avx-transit/blob/master/README.md
resource "aws_networkmanager_connect_peer" "peer1" {
  connect_attachment_id = aws_networkmanager_connect_attachment.avx_transit_vpc_connect_attachment.id
  peer_address          = module.mc-transit.transit_gateway.private_ip
  bgp_options {
    peer_asn = module.mc-transit.transit_gateway.local_as_number
  }
  inside_cidr_blocks = ["169.254.100.0/29"]
}

resource "aws_networkmanager_connect_peer" "peer2" {
  connect_attachment_id = aws_networkmanager_connect_attachment.avx_transit_vpc_connect_attachment.id
  peer_address          = module.mc-transit.transit_gateway.ha_private_ip
  bgp_options {
    peer_asn = module.mc-transit.transit_gateway.local_as_number
  }
  inside_cidr_blocks = ["169.254.100.8/29"]
}

resource "aws_networkmanager_connect_peer" "peer3" {
  connect_attachment_id = aws_networkmanager_connect_attachment.avx_transit_vpc_connect_attachment.id
  peer_address          = module.mc-transit.transit_gateway.private_ip
  bgp_options {
    peer_asn = module.mc-transit.transit_gateway.local_as_number
  }
  inside_cidr_blocks = ["169.254.100.16/29"]
}

resource "aws_networkmanager_connect_peer" "peer4" {
  connect_attachment_id = aws_networkmanager_connect_attachment.avx_transit_vpc_connect_attachment.id
  peer_address          = module.mc-transit.transit_gateway.ha_private_ip
  bgp_options {
    peer_asn = module.mc-transit.transit_gateway.local_as_number
  }
  inside_cidr_blocks = ["169.254.100.24/29"]
}

# Create GRE connection from Aviatrix to Edge Connect

resource "aviatrix_transit_external_device_conn" "connection1" {
  vpc_id             = module.mc-transit.vpc.vpc_id
  connection_name    = "connection1"
  gw_name            = module.mc-transit.transit_gateway.gw_name
  connection_type    = "bgp"
  tunnel_protocol    = "GRE"
  bgp_local_as_num   = module.mc-transit.transit_gateway.local_as_number
  bgp_remote_as_num  = 64800
  remote_gateway_ip  = "${aws_networkmanager_connect_peer.peer1.configuration[0].core_network_address},${aws_networkmanager_connect_peer.peer2.configuration[0].core_network_address}"
  direct_connect     = true
  ha_enabled         = false
  local_tunnel_cidr  = "169.254.100.1/29,169.254.100.9/29"
  remote_tunnel_cidr = "169.254.100.2/29,169.254.100.10/29"
}

resource "aviatrix_transit_external_device_conn" "connection2" {
  vpc_id             = module.mc-transit.vpc.vpc_id
  connection_name    = "connection2"
  gw_name            = module.mc-transit.transit_gateway.gw_name
  connection_type    = "bgp"
  tunnel_protocol    = "GRE"
  bgp_local_as_num   = module.mc-transit.transit_gateway.local_as_number
  bgp_remote_as_num  = 64800
  remote_gateway_ip  = "${aws_networkmanager_connect_peer.peer3.configuration[0].core_network_address},${aws_networkmanager_connect_peer.peer4.configuration[0].core_network_address}"
  direct_connect     = true
  ha_enabled         = false
  local_tunnel_cidr  = "169.254.100.17/29,169.254.100.25/29"
  remote_tunnel_cidr = "169.254.100.18/29,169.254.100.26/29"
}

