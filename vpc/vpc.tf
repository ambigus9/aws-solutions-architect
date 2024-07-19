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

  tags = {
    Name = "RT-AWS-LABS-PRIV"
  }
}

resource "aws_route_table_association" "rt_private_subnet_association" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.rt_private_subnet.id
}