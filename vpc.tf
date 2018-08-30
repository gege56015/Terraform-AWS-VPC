###################################################################
###  VPC
###################################################################
resource "aws_vpc" "main" {
  cidr_block = "${lookup(var.vpc_cidr, var.vpc_region)}"
  instance_tenancy = "${var.vpc_instance_tenancy}"
  enable_dns_support = "${var.vpc_enable_dns_resolution}"
  enable_dns_hostnames = "${var.vpc_enable_dns_hostnames}"
  tags {
    Name = "${var.vpc_name}"
    Environment = "${var.vpc_env_type}"
  }
}

###################################################################
###  Internet gateway 
###################################################################
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "${var.vpc_name}"
    Environment = "${var.vpc_env_type}"
  }
}

###################################################################
###  Public subnets
###################################################################
resource "aws_subnet" "public" {
    vpc_id            = "${aws_vpc.main.id}"
    count             = "${length(split(",", lookup(var.vpc_azs, var.vpc_region)))}"
    cidr_block        = "${element(split(",", lookup(var.vpc_public_subnets, var.vpc_region)), count.index)}"
    availability_zone = "${element(split(",", lookup(var.vpc_azs, var.vpc_region)), count.index)}"
    map_public_ip_on_launch = false

    tags {
        "Name" = "${lower(var.vpc_env_type_abbr)}-public-${element(split(",", lookup(var.vpc_azs, var.vpc_region)), count.index)}"
        Environment = "${var.vpc_env_type}"
        Tier = "Public"
    }
}

###################################################################
###  App subnets
###################################################################
resource "aws_subnet" "app" {
    vpc_id            = "${aws_vpc.main.id}"
    count             = "${length(split(",", lookup(var.vpc_azs, var.vpc_region)))}"
    cidr_block        = "${element(split(",", lookup(var.vpc_app_subnets, var.vpc_region)), count.index)}"
    availability_zone = "${element(split(",", lookup(var.vpc_azs, var.vpc_region)), count.index)}"
    map_public_ip_on_launch = false

    tags {
        "Name" = "${lower(var.vpc_env_type_abbr)}-app-${element(split(",", lookup(var.vpc_azs, var.vpc_region)), count.index)}"
        Environment = "${var.vpc_env_type}"
        Tier = "App"
    }
}

###################################################################
###  Data subnets
###################################################################
resource "aws_subnet" "data" {
    vpc_id            = "${aws_vpc.main.id}"
    count             = "${length(split(",", lookup(var.vpc_azs, var.vpc_region)))}"
    cidr_block        = "${element(split(",", lookup(var.vpc_data_subnets, var.vpc_region)), count.index)}"
    availability_zone = "${element(split(",", lookup(var.vpc_azs, var.vpc_region)), count.index)}"
    map_public_ip_on_launch = false

    tags {
        "Name" = "${lower(var.vpc_env_type_abbr)}-data-${element(split(",", lookup(var.vpc_azs, var.vpc_region)), count.index)}"
        Environment = "${var.vpc_env_type}"
        Tier = "Data"
    }
}

###################################################################
###  EIPs for NAT Gateways
###################################################################
resource "aws_eip" "nat" {
  count = "${length(split(",", lookup(var.vpc_public_subnets, var.vpc_region)))}"
  vpc = true
  tags {
        "Name" = "${lower(var.vpc_env_type_abbr)}-public-${element(split(",", lookup(var.vpc_azs, var.vpc_region)), count.index)}"
        Environment = "${var.vpc_env_type}"
    }
}

###################################################################
###  NAT Gateways
###################################################################
resource "aws_nat_gateway" "nat" {
  count = "${length(split(",", lookup(var.vpc_public_subnets, var.vpc_region)))}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  tags {
        "Name" = "${lower(var.vpc_env_type_abbr)}-public-${element(split(",", lookup(var.vpc_azs, var.vpc_region)), count.index)}"
        Environment = "${var.vpc_env_type}"
    }
  depends_on = ["aws_internet_gateway.main"]
}

###################################################################
###  Default Route Table
###################################################################
resource "aws_default_route_table" "local_net_access" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"
  tags {
    "Name" = "${lower(var.vpc_env_type_abbr)}-default"
    Environment = "${var.vpc_env_type}"
  }
}

###################################################################
###  Public route tables
###################################################################
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  count = "${length(split(",", lookup(var.vpc_public_subnets, var.vpc_region)))}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags {
    Name = "${lower(var.vpc_env_type_abbr)}-public-${element(split(",", lookup(var.vpc_azs, var.vpc_region)), count.index)}"
    Environment = "${var.vpc_env_type}"
  }
}

###################################################################
###  App route tables
###################################################################
resource "aws_route_table" "app" {
  vpc_id = "${aws_vpc.main.id}"
  count = "${length(split(",", lookup(var.vpc_app_subnets, var.vpc_region)))}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }
  tags {
    Name = "${lower(var.vpc_env_type_abbr)}-app-${element(split(",", lookup(var.vpc_azs, var.vpc_region)), count.index)}"
    Environment = "${var.vpc_env_type}"
  }
}

###################################################################
###  Data route tables
###################################################################
resource "aws_route_table" "data" {
  vpc_id = "${aws_vpc.main.id}"
  count = "${length(split(",", lookup(var.vpc_data_subnets, var.vpc_region)))}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }
  tags {
    Name = "${lower(var.vpc_env_type_abbr)}-data-${element(split(",", lookup(var.vpc_azs, var.vpc_region)), count.index)}"
    Environment = "${var.vpc_env_type}"
  }
}

###################################################################
###  Associate public subnets with public route tables
###################################################################
resource "aws_route_table_association" "public" {
  count          = "${length(split(",", lookup(var.vpc_azs, var.vpc_region)))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

###################################################################
###  Associate app subnets with app route tables
###################################################################
resource "aws_route_table_association" "app" {
  count          = "${length(split(",", lookup(var.vpc_azs, var.vpc_region)))}"
  subnet_id      = "${element(aws_subnet.app.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.app.*.id, count.index)}"
}

###################################################################
###  Associate data subnets with data route tables
###################################################################
resource "aws_route_table_association" "data" {
  count          = "${length(split(",", lookup(var.vpc_azs, var.vpc_region)))}"
  subnet_id      = "${element(aws_subnet.data.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.data.*.id, count.index)}"
}

output "aws_vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "aws_vpc_cidr" {
  value = "${aws_vpc.main.cidr_block}"
}

output "aws_public_subnet_ids" {
  value = ["${aws_subnet.public.*.id}"]
}

output "aws_app_subnet_ids" {
  value = ["${aws_subnet.app.*.id}"]
}

output "aws_data_subnet_ids" {
  value = ["${aws_subnet.data.*.id}"]
}

output "aws_public_route_table_ids" {
  value = ["${aws_route_table.public.*.id}"]
}

output "aws_app_route_table_ids" {
  value = ["${aws_route_table.app.*.id}"]
}

output "aws_data_route_table_ids" {
  value = ["${aws_route_table.data.*.id}"]
}

output "aws_default_route_table_id" {
  value = ["${aws_default_route_table.local_net_access.id}"]
}