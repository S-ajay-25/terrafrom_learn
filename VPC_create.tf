provider "aws" {
  region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

resource "aws_vpc" "first_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.first_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.first_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Private"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.first_vpc.id

  tags = {
    Name = "Internet-Gateway"
  }
}


resource "aws_eip" "ip" {
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ip
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = "NGW"
  }
}

resource "aws_route_table" "route_table_1" {
  vpc_id = aws_vpc.first_vpc.id

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name  = "custom"
  }
}

resource "aws_route_table" "route_table_2" {
  vpc_id = aws_vpc.first_vpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_nat_gateway.ngw.id
  }
   tags = {
    Name  = "main"
  }
}

resource "aws_route_table_association" "associate_route_1" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table_1.id
}

resource "aws_route_table_association" "associate_route_2" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.route_table_2.id
}


resource "aws_security_group" "security_group" {
  name        = "first-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.first_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.first_vpc.cidr_block]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "first-SG"
  }
}