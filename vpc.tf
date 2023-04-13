resource "aws_vpc" "my_vpc_test" {
  cidr_block = "10.0.0.0/28"
  tags = {
    Name = "my-vpc-test"
  }
}

resource "aws_subnet" "my_subnet_test" {
  vpc_id                  = aws_vpc.my_vpc_test.id
  cidr_block              = "10.0.0.0/28"
  availability_zone_id    = "aps1-az1"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet-test"
  }
}
resource "aws_internet_gateway" "my_test_Ig" {
  vpc_id = aws_vpc.my_vpc_test.id


  tags = {
    Name = "my-test-ig"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc_test.id

  tags = {
    Name = "my-test-route-table"
  }
}

resource "aws_route_table_association" "my_subnet_vpc_route_table_association" {
  subnet_id      = aws_subnet.my_subnet_test.id
  route_table_id = aws_route_table.my_route_table.id

}

resource "aws_route" "my_route" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_test_Ig.id
}

