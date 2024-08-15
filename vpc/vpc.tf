resource "aws_vpc" "vpc_lab" {
  cidr_block = "192.168.0.0/22" # 1000 Host
  tags = {
    Name = "AWS-LABS"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id     = aws_vpc.vpc_lab.id
  cidr_block = "192.168.0.0/24" # 251 Avaible IP's
  availability_zone = "us-east-1a"
  tags = {
    Name = "SUBNET-PUB-A"
  }
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id     = aws_vpc.vpc_lab.id
  cidr_block = "192.168.2.0/23" # 507 Avaible IP's
  availability_zone = "us-east-1a"
  tags = {
    Name = "SUBNET-PRIV-A"
  }
}

resource "aws_route_table" "rt_public_subnet" {
  vpc_id = aws_vpc.vpc_lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "RT-AWS-LABS-PUB"
  }
}

resource "aws_route_table_association" "rt_public_subnet_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.rt_public_subnet.id
}


resource "aws_route_table" "rt_private_subnet" {
  vpc_id = aws_vpc.vpc_lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my_nat_gw.id
  }

  tags = {
    Name = "RT-AWS-LABS-PRIV"
  }
}

resource "aws_route_table_association" "rt_private_subnet_association" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.rt_private_subnet.id
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.vpc_lab.id

  tags = {
    Name = "IGW-AWS-LABS"
  }
}

resource "aws_nat_gateway" "my_nat_gw" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.my_public_subnet.id

  tags = {
    Name = "NAT-AWS-LABS"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my_igw]
}

resource "aws_eip" "my_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.my_igw]
}

resource "aws_network_acl" "my_network_acl" {
  vpc_id = aws_vpc.vpc_lab.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Name = "NACL-AWS-LABS"
  }
}


resource "aws_security_group" "app_sg" {
  name        = "APP-SG"
  description = "SG-WEB"
  vpc_id      = aws_vpc.vpc_lab.id

  tags = {
    Name = "app_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description = "Port 80 Rule"
}