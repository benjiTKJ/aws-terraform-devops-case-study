# Singapore Internet Gateway with 2 public subnet for each AZ
resource "aws_internet_gateway" "sg_vpc_igw" {
  vpc_id = aws_vpc.sg_vpc.id

  tags = {
    Environment = var.environment
  }
}

resource "aws_route_table" "sg_vpc_public" {
  vpc_id = aws_vpc.sg_vpc.id

  route {
      cidr_block = var.all_access_cidr
      gateway_id = aws_internet_gateway.sg_vpc_igw.id
  }


  tags = {
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_to_tier_1_a" {
  subnet_id      = aws_subnet.sg_tier_1_a.id
  route_table_id = aws_route_table.sg_vpc_public.id
}

resource "aws_route_table_association" "public_to_tier_1_b" {
  subnet_id      = aws_subnet.sg_tier_1_b.id
  route_table_id = aws_route_table.sg_vpc_public.id
}

# US Internet Gateway
resource "aws_internet_gateway" "us_vpc_igw" {
  vpc_id = aws_vpc.us_vpc.id

  tags = {
    Environment = var.environment
  }
}

resource "aws_route_table" "us_vpc_public" {
  vpc_id = aws_vpc.us_vpc.id

  route {
      cidr_block = var.all_access_cidr
      gateway_id = aws_internet_gateway.us_vpc_igw.id
  }


  tags = {
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_to_tier_1_a" {
  subnet_id      = aws_subnet.us_tier_1_a.id
  route_table_id = aws_route_table.us_vpc_public.id
}

resource "aws_route_table_association" "public_to_tier_1_b" {
  subnet_id      = aws_subnet.us_tier_1_b.id
  route_table_id = aws_route_table.us_vpc_public.id
}