resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_subnet" "this" {
  for_each   = var.subnets
  vpc_id     = aws_vpc.this.id
  cidr_block = each.value.cidr_block

  tags = {
    Name = "${aws_vpc.this.tags.Name}-${each.key}"
  }
  availability_zone = each.value.availability_zone
}

resource "aws_route_table" "public" {
  vpc_id   = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${aws_vpc.this.tags.Name}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id   = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-private-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.this["public"].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.this["private"].id
  route_table_id = aws_route_table.private.id
}
