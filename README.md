# terraform-cloud-wan-avx-transit-secure-egress

## This module creates following architecture
![architecture](CloudWAN-Aviatrix-Transit-Secure-Egress.png)

- One core global network
- Global network have ASN range and Inside CIDR Blocks configured
- An Core Network Edge defined in policy for us-east-1
- Assign one ASN and one Inside CIDR Block to tje us-east-1 Core Network Edge