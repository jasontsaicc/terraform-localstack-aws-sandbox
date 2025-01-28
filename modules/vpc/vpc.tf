# -------------------------
# VPC
# -------------------------
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-vpc"
    Environment = "dev"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-igw"
    Environment = "dev"
  }
}

# -------------------------
# Public Subnets (each AZ)
# -------------------------
resource "aws_subnet" "public" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.this.id
  cidr_block             = var.public_subnet_cidrs[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Environment = "dev"
  }
}

# Public Route Table & default route → IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-public-rt"
    Environment = "dev"
  }
}

resource "aws_route" "public_route_igw" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Subnet association to Public RT
resource "aws_route_table_association" "public_rta" {
  count          = length(local.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------
# NAT Gateway (建議至少每個 AZ 都建立一個)
# -------------------------
resource "aws_eip" "nat_eip" {
  # count = length(local.availability_zones)
  domain   = "vpc"
  tags = {
    Name = "${var.project_name}-nat-eip-ap-southeast-1a"
    Environment = "dev"
  }
}

resource "aws_nat_gateway" "this" {
  # count         = aws_eip.nat_eip.id
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id    # 只使用 ap-southeast-1a 的 Public Subnet
  tags = {
    Name = "${var.project_name}-nat-gw-ap-southeast-1a"
    Environment = "dev"
  }
  depends_on = [aws_internet_gateway.this]
}

# -------------------------
# Private Subnets (each AZ)
# -------------------------
resource "aws_subnet" "private" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.this.id
  cidr_block             = var.private_subnet_cidrs[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Environment = "dev"
  }
}

resource "aws_route_table" "private_rt" {
  count = length(local.availability_zones)
  vpc_id = aws_vpc.this.id
  tags = { 
    Name = "${var.project_name}-private-rt-${count.index + 1}"
    Environment = "dev" 
    }
}

# Each Private Route → NAT Gateway in same AZ
resource "aws_route" "private_route_nat" {
  count                   = length(local.availability_zones)
  route_table_id         = aws_route_table.private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

# Subnet association to Private RT
resource "aws_route_table_association" "private_rta" {
  count          = length(local.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}

# -------------------------
# Locals
# -------------------------
locals {
  availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]
}
