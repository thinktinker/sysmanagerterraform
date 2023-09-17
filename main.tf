resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.name_prefix}-ssm-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-ssm-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.name_prefix}-ssm-public"
  }
}

# Creating an Route Table for the public subnet!
resource "aws_route_table" "Public-Subnet-RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Route Table for ${var.name_prefix}-ssm-public"
  }
}

resource "aws_route_table_association" "RT-IG-Association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.Public-Subnet-RT.id
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.name_prefix}-ssm-private"
  }
}

resource "aws_eip" "natgw" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-ssm-eip"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "${var.name_prefix}-ssm-nat"
  }
}

resource "aws_route_table" "Private-Subnet-RT" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "Route Table for ${var.name_prefix}-ssm-private"
  }
}

resource "aws_route_table_association" "RT-Private-Association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.Private-Subnet-RT.id
}

resource "aws_security_group" "example" {
  name   = "${var.name_prefix}-private-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-private-sg"
  }
}

resource "aws_instance" "private" {
  ami                  = data.aws_ami.amazon2.id
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.private.id
  iam_instance_profile = aws_iam_instance_profile.example.name

  tags = {
    Name = "${var.name_prefix}-private"
  }
}
