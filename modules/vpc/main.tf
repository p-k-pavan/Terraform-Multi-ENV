resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.vpc_name}-vpc"
    Environment = "${var.env}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.vpc_name}-igw"
    Environment = "${var.env}"
  }
}

resource "aws_subnet" "public-subnets" {
  count             = length(var.public_cidr_block)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_cidr_block, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name        = "${var.vpc_name}-public-subnet-${count.index + 1}"
    Environment = "${var.env}"
  }
}

resource "aws_subnet" "private-subnets" {
  count             = length(var.private_cidr_block)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_cidr_block, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name        = "${var.vpc_name}-private-subnet-${count.index + 1}"
    Environment = "${var.env}"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name        = "${var.vpc_name}-public-route-table"
    Environment = "${var.env}"
  }

}

resource "aws_route_table_association" "public-route-table-association" {
  count          = length(var.public_cidr_block)
  subnet_id      = element(aws_subnet.public-subnets.*.id, count.index)
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_eip" "nat-eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnets.0.id

  tags = {
    Name        = "${var.vpc_name}-nat-gateway"
    Environment = "${var.env}"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name        = "${var.vpc_name}-private-route-table"
    Environment = "${var.env}"
  }

}

resource "aws_route_table_association" "private-route-table-association" {
  count          = length(var.private_cidr_block)
  subnet_id      = element(aws_subnet.private-subnets.*.id, count.index)
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_security_group" "sg" {
  name        = "${var.vpc_name}-security-group"
  description = "security gruoup"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.service_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.vpc_name}-igw"
    Environment = "${var.env}"
  }

}
