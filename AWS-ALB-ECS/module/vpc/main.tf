variable "vpc_cidr" {}
variable "availability_zones" {}
variable "private_subnets_cidr" {}


output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "private_subnet_id" {
  value = aws_subnet.my_private_subnet[*].id
}


resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "my_private_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_vpc.my_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}
