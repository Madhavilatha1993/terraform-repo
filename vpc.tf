provider "aws" {
     region = var.region
   
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

   tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  availability_zone = var.public_subnet_az

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr
  availability_zone = var.private_subnet_az

  tags = {
    Name = "private-subnet"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw_main"
  }
}
resource "aws_eip" "eip" {

      tags = {
    Name = "nat-eip"
  }
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet_a.id

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = var.cidr_block_rt
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "public-routetable"
    }
  
}
resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = var.cidr_block_rt
        nat_gateway_id = aws_nat_gateway.nat_gw.id
    }
  tags = {
    Name = "private-routetable"
  }
}
resource "aws_route_table_association" "private_subnet" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}

