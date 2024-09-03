variable "vpc_cidr" {}
variable "availability_zones" {}
variable "private_subnets_cidr" {}
variable "public_subnets_cidr" {}


output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.my_public_subnet[*].id
}

output "private_subnet_id" {
  value = aws_subnet.my_private_subnet[*].id
}


resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  count             = length(var.availability_zones)
  cidr_block        = var.public_subnets_cidr[count.index]
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "My Public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  count             = length(var.availability_zones)
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "My Private subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My Internet Gateway"
  }
}

resource "aws_route_table" "my_route_table_public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "My Public subnet Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.my_route_table_public_subnet.id
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.my_public_subnet[*].id, count.index)
}


resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.my_igw]
  tags = {
    Name = "My Elastic IP"
  }
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = element(aws_subnet.my_public_subnet[*].id, 0)
  depends_on    = [aws_internet_gateway.my_igw]
  tags = {
    Name = "My Nat Gateway"
  }
}


resource "aws_route_table" "my_route_table_private_subnet" {
  depends_on = [aws_nat_gateway.my_nat_gateway]
  vpc_id     = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my_nat_gateway.id
  }
  tags = {
    Name = "Private subnet Route Table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  route_table_id = aws_route_table.my_route_table_private_subnet.id
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.my_private_subnet[*].id, count.index)
}

