/*===== The VPC ======*/
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_hostnames = var.enable_dns_hostnames
    # False by default.

    tags = merge(
        var.common_tags,
        var.vpc_tags,
        {
            Name = local.resource_name
        }
    )
}


/*===== Subnets ======*/

/*** Internet gateway for the public subnet ***/
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        Name = local.resource_name
    }
  )
}

/*** Elastic IP for NAT Gateway ***/
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.ig ]
   # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
}

/*** NAT Gateway for the private subnets ***/
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet[0].id

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
      Name = "${local.resource_name}"
    }
  )
}

/*** Public subnet ***/
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    var.public_subnet_cidrs_tags,
    {
      Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }
  )
}

/*** Private subnet ***/
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.private_subnet_cidrs)
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_cidr_tags,
    {
      Name = "${local.resource_name}-private-${local.az_names[count.index]}"
    }
  )
}

/*** Database subnet ***/
resource "aws_subnet" "database_subnet" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.database_subnet_cidrs)
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_cidr_tags,
    {
      Name = "${local.resource_name}-database-${local.az_names[count.index]}"
    }
  )
}

/*** Database subnet Group ***/
resource "aws_db_subnet_group" "default" {
  name = "${local.resource_name}"
  subnet_ids = aws_subnet.database_subnet[*].id

  tags = merge(
    var.common_tags,
    var.database_subnet_group_tags,
    {
      Name ="${local.resource_name}"
    }
  )
}

/*** Routing table for public subnet ***/
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
      Name ="${local.resource_name}-public"   # expense-dev-public
    }
  )
}

/*** Routing table for private subnet ***/
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
      Name ="${local.resource_name}-private"   
    }
  )
}

/*** Routing table for database subnet ***/
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
    {
      Name ="${local.resource_name}-database"   
    }
  )
}

/*** routes ***/
resource "aws_route" "public_internet_gateway" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route" "database_nat_gateway" {
  route_table_id = aws_route_table.databse.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat.id
}

/*** Route table and Subnet associations ***/
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id = element(aws_subnet.databse_subnet[*].id, count.index)
  route_table_id = aws_route_table.database.id
}
