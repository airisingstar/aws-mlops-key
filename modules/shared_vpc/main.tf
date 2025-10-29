# Minimal, production-friendly VPC with two private subnets.
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.name_prefix}-vpc" }
}

# Private Subnet A
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 1)
  availability_zone = "${var.region}a"
  tags = { Name = "${var.name_prefix}-subnet-a" }
}

# Private Subnet B
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 2)
  availability_zone = "${var.region}b"
  tags = { Name = "${var.name_prefix}-subnet-b" }
}

output "vpc_id"     { value = aws_vpc.main.id }
output "subnet_ids" { value = [aws_subnet.private_a.id, aws_subnet.private_b.id] }
