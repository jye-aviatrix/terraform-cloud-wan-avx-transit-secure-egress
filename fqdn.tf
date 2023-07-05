resource "aviatrix_fqdn" "fqdn" {
    fqdn_mode = "black"
    fqdn_enabled = true


    dynamic "gw_filter_tag_list" {
        for_each = module.mc-firenet.aviatrix_firewall_instance[*].id
        content {
          gw_name = gw_filter_tag_list.value
        }
      
    }

    fqdn_tag = "internet"
    manage_domain_names = false
}

