# On Avx Transit VPC route table for Public-gateway-and-firewall-mgmt subnets, add inside-cidr-blocks assigned to Core Network Policy point to Core Network
resource "aws_route" "avx_transit_Public-gateway-and-firewall-mgmt_subnet_rt" {
  route_table_id            = var.avx_transit_Public-gateway-and-firewall-mgmt_subnet_rt_id # Lookup Aviatrix Transit VPC subnet with the name: Public-gateway-and-firewall-mgmt, then lookup the route table ID associated with the subnet
  destination_cidr_block    = var.global_edge_inside_cidr_blocks
  core_network_arn = aws_networkmanager_core_network.this.arn
  depends_on = [
    module.mc-transit
  ]
}