# Singapore VPC 
resource "aws_vpc" "sg_vpc" {
  provider          = aws.ap-southeast-1
  cidr_block        = var.vpc_cidr
  instance_tenancy  = "default"
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  tags = {
    Environment = var.environment
  }
}

resource "aws_default_network_acl" "sg_vpc_main_nacl" {
  provider               = aws.ap-southeast-1
  default_network_acl_id = aws_vpc.sg_vpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.all_access_cidr
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.all_access_cidr
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_default_route_table" "sg_vpc_main_route_table" {
  provider               = aws.ap-southeast-1
  default_route_table_id = aws_vpc.sg_vpc.default_route_table_id

  route {
    cidr_block = var.all_access_cidr
    gateway_id = aws_internet_gateway.sg_vpc_igw.id
  }

  tags = {
    Environment = var.environment
  }
}

# US VPC
resource "aws_vpc" "us_vpc" {
  provider          = aws.us-east-1
  cidr_block        = var.vpc_cidr
  instance_tenancy  = "default"
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  tags = {
    Environment = var.environment
  }
}

resource "aws_default_network_acl" "us_vpc_main_nacl" {
  provider               = aws.us-east-1
  default_network_acl_id = aws_vpc.us_vpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.all_access_cidr
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.all_access_cidr
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_default_route_table" "us_vpc_main_route_table" {
  provider               = aws.us-east-1
  default_route_table_id = aws_vpc.us_vpc.default_route_table_id

  route {
    cidr_block = var.all_access_cidr
    gateway_id = aws_internet_gateway.us_vpc_igw.id
  }

  tags = {
    Environment = var.environment
  }
}