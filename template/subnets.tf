# Singapore subnets
resource "aws_subnet" "sg_tier_1_a" {
  provider                = aws.ap-southeast-1
  vpc_id                  = aws_vpc.sg_vpc.id
  cidr_block              = var.tier_1_a_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.sg_availability_zones[0]

  tags                    = {
    Environment           = var.environment
  }
}

resource "aws_subnet" "sg_tier_1_b" {
  provider                = aws.ap-southeast-1
  vpc_id                  = aws_vpc.sg_vpc.id
  cidr_block              = var.tier_1_b_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.sg_availability_zones[1]

  tags                    = {
    Environment           = var.environment
  }
}

resource "aws_subnet" "sg_tier_2_a" {
  provider                = aws.ap-southeast-1
  vpc_id                  = aws_vpc.sg_vpc.id
  cidr_block              = var.tier_2_a_cidr
  map_public_ip_on_launch = false
  availability_zone       = var.sg_availability_zones[0]

  tags                    = {
    Environment           = var.environment
  }
}

resource "aws_subnet" "sg_tier_2_b" {
  provider                = aws.ap-southeast-1
  vpc_id                  = aws_vpc.sg_vpc.id
  cidr_block              = var.tier_2_b_cidr
  map_public_ip_on_launch = false
  availability_zone       = var.sg_availability_zones[1]

  tags                    = {
    Environment           = var.environment
  }
}

# US subnets
resource "aws_subnet" "us_tier_1_a" {
  provider                = aws.us-east-1
  vpc_id                  = aws_vpc.us_vpc.id
  cidr_block              = var.tier_1_a_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.us_availability_zones[0]

  tags                    = {
    Environment           = var.environment
  }
}

resource "aws_subnet" "us_tier_1_b" {
  provider                = aws.us-east-1
  vpc_id                  = aws_vpc.us_vpc.id
  cidr_block              = var.tier_1_b_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.us_availability_zones[1]

  tags                    = {
    Environment           = var.environment
  }
}

resource "aws_subnet" "us_tier_2_a" {
  provider                = aws.us-east-1
  vpc_id                  = aws_vpc.us_vpc.id
  cidr_block              = var.tier_2_a_cidr
  map_public_ip_on_launch = false
  availability_zone       = var.us_availability_zones[0]

  tags                    = {
    Environment           = var.environment
  }
}

resource "aws_subnet" "us_tier_2_b" {
  provider                = aws.us-east-1
  vpc_id                  = aws_vpc.us_vpc.id
  cidr_block              = var.tier_2_b_cidr
  map_public_ip_on_launch = false
  availability_zone       = var.us_availability_zones[1]

  tags                    = {
    Environment           = var.environment
  }
}