resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.common_tags, { Name = "${var.project_name}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.common_tags, { Name = "${var.project_name}-igw" })
}

# Public subnets (map_public_ip_on_launch = true)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_a_cidr
  availability_zone       = var.az_names[0]
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, { Name = "${var.project_name}-public-a", Tier = "web" })
}
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_b_cidr
  availability_zone       = var.az_names[1]
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, { Name = "${var.project_name}-public-b", Tier = "web" })
}

# Private app subnets
resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_a_cidr
  availability_zone = var.az_names[0]
  tags = merge(var.common_tags, { Name = "${var.project_name}-app-a", Tier = "app" })
}
resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_b_cidr
  availability_zone = var.az_names[1]
  tags = merge(var.common_tags, { Name = "${var.project_name}-app-b", Tier = "app" })
}

# Private DB subnets
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_a_cidr
  availability_zone = var.az_names[0]
  tags = merge(var.common_tags, { Name = "${var.project_name}-db-a", Tier = "db" })
}
resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_b_cidr
  availability_zone = var.az_names[1]
  tags = merge(var.common_tags, { Name = "${var.project_name}-db-b", Tier = "db" })
}

# Public route table + routes
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.common_tags, { Name = "${var.project_name}-rt-public" })
}
resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Optional NAT for app subnets
resource "aws_eip" "nat" {
  count      = var.enable_nat ? 1 : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags       = merge(var.common_tags, { Name = "${var.project_name}-nat-eip" })
}
resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_a.id
  tags          = merge(var.common_tags, { Name = "${var.project_name}-nat" })
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.common_tags, { Name = "${var.project_name}-rt-app" })
}
resource "aws_route" "app_nat" {
  count                  = var.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}
resource "aws_route_table_association" "app_a" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.app.id
}
resource "aws_route_table_association" "app_b" {
  subnet_id      = aws_subnet.app_b.id
  route_table_id = aws_route_table.app.id
}

# DB route table (no internet route)
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.common_tags, { Name = "${var.project_name}-rt-db" })
}
resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.db.id
}
resource "aws_route_table_association" "db_b" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.db.id
}

# S3 endpoint for private subnets (app+db)
resource "aws_vpc_endpoint" "s3" {
  vpc_id           = aws_vpc.this.id
  service_name     = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids  = [aws_route_table.app.id, aws_route_table.db.id]
  tags             = merge(var.common_tags, { Name = "${var.project_name}-s3-endpoint" })
}