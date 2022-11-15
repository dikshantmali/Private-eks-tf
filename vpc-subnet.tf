# the  below resource will configure a VPC in aws

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

# assigning internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Personal prod Internet gateway"
  }
}
# EIP for NAT gateway
resource "aws_eip" "eip" {
vpc = true
tags = {
    Name = "EIP for Personal prod gw NAT"
  }
}

# NAT gateway for private subnets

resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "Personal prod gw NAT"
  }

  depends_on = [aws_internet_gateway.gw]
}

# the below resources will configure 3 public and 3 private subnets in aws us-east-1 region

resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
      map_public_ip_on_launch = true

  tags = {
    Name = "Public-subnet-1"
  }
}
resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

  tags = {
    Name = "Public-subnet-2"
  }
}
resource "aws_subnet" "public-subnet-3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
    map_public_ip_on_launch = true
  tags = {
    Name = "Public-subnet-3"
  }
}
resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
availability_zone = "us-east-1a"
  tags = {
    Name = "Private-subnet-1"
  }
}
resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
availability_zone = "us-east-1b"
  tags = {
    Name = "Private-subnet-2"
  }
}
resource "aws_subnet" "private-subnet-3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.6.0/24"
availability_zone = "us-east-1c"
  tags = {
    Name = "Private-subnet-3"
  }
}


# configuring route tables

# route table for pubic subnet

resource "aws_route_table" "public-subnet-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "personal-prod-public-subnet-rt"
  }
}

resource "aws_route_table_association" "associate-public-subnet-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-subnet-rt.id
}
resource "aws_route_table_association" "associate-public-subnet-2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-subnet-rt.id
}
resource "aws_route_table_association" "associate-public-subnet-3" {
  subnet_id      = aws_subnet.public-subnet-3.id
  route_table_id = aws_route_table.public-subnet-rt.id
}

# route table for private subnet

resource "aws_route_table" "private-subnet-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ng.id
  }


  tags = {
    Name = "personal-prod-private-subnet-rt"
  }
}

resource "aws_route_table_association" "associate-private-subnet-1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-subnet-rt.id
}
resource "aws_route_table_association" "associate-private-subnet-2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-subnet-rt.id
}
resource "aws_route_table_association" "associate-private-subnet-3" {
  subnet_id      = aws_subnet.private-subnet-3.id
  route_table_id = aws_route_table.private-subnet-rt.id
}