# VPC Module

Modular Terraform configuration for creating an AWS VPC with public and private subnets across multiple availability zones.

## Features

- **VPC** with configurable CIDR block and DNS settings
- **Public subnets** with internet gateway access
- **Private subnets** with NAT gateway for outbound connectivity
- **Cost optimization** with single NAT gateway option
- **Multi-AZ support** for high availability

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr              = "10.0.0.0/24"
  availability_zones    = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs   = ["10.0.0.0/26", "10.0.0.64/26"]
  private_subnet_cidrs  = ["10.0.0.128/26", "10.0.0.192/26"]
  enable_nat_gateway    = true
  single_nat_gateway    = true
  environment           = "sandbox"
  tags                  = {
    Project = "load-test"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_cidr | CIDR block for VPC | string | "10.0.0.0/24" | no |
| availability_zones | List of availability zones | list(string) | ["us-east-1a", "us-east-1b"] | no |
| public_subnet_cidrs | CIDR blocks for public subnets | list(string) | ["10.0.0.0/26", "10.0.0.64/26"] | no |
| private_subnet_cidrs | CIDR blocks for private subnets | list(string) | ["10.0.0.128/26", "10.0.0.192/26"] | no |
| enable_nat_gateway | Enable NAT Gateway | bool | true | no |
| single_nat_gateway | Use single NAT Gateway (cost optimization) | bool | true | no |
| enable_dns_hostnames | Enable DNS hostnames in VPC | bool | true | no |
| enable_dns_support | Enable DNS support in VPC | bool | true | no |
| environment | Environment name | string | - | yes |
| tags | Additional tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| internet_gateway_id | Internet Gateway ID |
| nat_gateway_ids | List of NAT Gateway IDs |
| nat_gateway_public_ips | Public IPs of NAT Gateways |
| public_route_table_id | Public route table ID |
| private_route_table_ids | Private route table IDs |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/24)                    │
│                                                              │
│  ┌────────────────────────┐  ┌────────────────────────┐   │
│  │  Public Subnet 1       │  │  Public Subnet 2       │   │
│  │  10.0.0.0/26           │  │  10.0.0.64/26          │   │
│  │  (us-east-1a)          │  │  (us-east-1b)          │   │
│  │  ┌──────────────┐      │  │                        │   │
│  │  │ NAT Gateway  │      │  │                        │   │
│  │  └──────────────┘      │  │                        │   │
│  └─────────┬──────────────┘  └────────────────────────┘   │
│            │                                                │
│  ┌─────────┴──────────────┐  ┌────────────────────────┐   │
│  │  Private Subnet 1      │  │  Private Subnet 2      │   │
│  │  10.0.0.128/26         │  │  10.0.0.192/26         │   │
│  │  (us-east-1a)          │  │  (us-east-1b)          │   │
│  └────────────────────────┘  └────────────────────────┘   │
│                                                              │
└──────────────────────┬───────────────────────────────────────┘
                       │
                 Internet Gateway
                       │
                   Internet
```

## Cost Considerations

- **Single NAT Gateway**: ~$32/month (recommended for sandbox/dev)
- **Multi-AZ NAT Gateway**: ~$32/month per AZ (recommended for production)
- **Data Processing**: ~$0.045 per GB through NAT Gateway

## Notes

- For sandbox environments, use `single_nat_gateway = true` to reduce costs
- For production, use one NAT Gateway per AZ for high availability
- All subnets are spread across multiple availability zones for redundancy
