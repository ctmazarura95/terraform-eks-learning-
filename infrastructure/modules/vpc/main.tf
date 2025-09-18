data "aws_availability_zones" "az"{
    state = "available"
}

resource "aws_vpc" "main" {
  
  cidr_block = var.vpc_cidr 
  enable_dns_hostnames = true
  enable_dns_support = true


}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  // count length of public_subnet variable 
  count = length(var.public_subnet)
  // iteratively set cidrblock for subnets using public_subnet variable index key   
  cidr_block = var.public_subnet[count.index]

 //create tags for each subnet to have public-1-az  
tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  // count length of private_subnet variable 
  count = length(var.private_subnet)
  // iteratively set cidrblock for subnets using private_subnet variable index key   
  cidr_block = var.private_subnet[count.index]

 //create tags for each subnet to have private-1-az  
tags = {
    Name = "private-subnet-${count.index}"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "public-rt"
  }

 
}
resource "aws_route_table_association" "public-rt-association" {
  count = length(var.public_subnet)  
  subnet_id      = aws_subnet.public[count.index].id  
  route_table_id = aws_route_table.public-rt
}

// create elastic eip  to be used for private-rt    
resource "aws_eip" "nat" {
  vpc = true
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "NAT Gateway"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}


resource "aws_route_table_association" "private-rt-association" {
  count = length(var.private_subnet)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-rt.id
}


