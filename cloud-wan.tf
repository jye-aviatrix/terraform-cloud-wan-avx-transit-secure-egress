resource "aws_networkmanager_global_network" "this" {
  tags = {
    "Name" = "CWAN-Global-Network"
  }
}


resource "aws_networkmanager_core_network" "this" {

  global_network_id = aws_networkmanager_global_network.this.id

  tags = {
    Name = "Core Network General Settings"
  }
}

resource "aws_networkmanager_core_network_policy_attachment" "this" {
  core_network_id = aws_networkmanager_core_network.this.id
  policy_document = data.aws_networkmanager_core_network_policy_document.this.json
}


data "aws_networkmanager_core_network_policy_document" "this" {
  core_network_configuration {
    vpn_ecmp_support = true
    asn_ranges       = ["64800-64810"]
    inside_cidr_blocks = [var.global_edge_inside_cidr_blocks]
    edge_locations {
      location = var.region
      asn      = 64800
      inside_cidr_blocks = [var.use1_edge_inside_cidr_blocks] # (Optional) - The local CIDR blocks for this Core Network Edge for AWS Transit Gateway Connect attachments.
    }
  }

  segments {
    name                          = "default"
    description                   = "default segments"
    require_attachment_acceptance = false
    isolate_attachments           = false
  }

  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "segment"
      value    = "default"
    }
    action {
      association_method = "constant"
      segment            = "default"
    }
  }



}

resource "aws_networkmanager_vpc_attachment" "this" {
  for_each        = var.vpcs
  subnet_arns     = module.vpc[each.key].subnet_arns
  core_network_id = aws_networkmanager_core_network.this.id
  vpc_arn         = module.vpc[each.key].vpc_arn
  tags = {
    segment = "default"
  }
}


resource "aws_route" "private_subnet_default_route" {
  for_each        = var.vpcs
  route_table_id            = module.vpc[each.key].private_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  core_network_arn = aws_networkmanager_core_network.this.arn
}