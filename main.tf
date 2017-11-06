/**
# Subnet in VPC Terraform Module
========================================

A Terraform module to create subnets in a AWS VPC

 * Usage:
 * --------
 *
 *      module "subnet" {
 *        source       = "../tf_subnet"
 *
 *        name         = "production-public"
 *        environment  = "dev"
 *        cidrs        = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
 *        azs          = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
 *        vpc_id       = "vpc-12345678"
 *        igw_id       = "igw-12345678"
 *
 *        tags {
 *          "Terraform" = "true"
 *        }
 *      }
**/

resource "aws_subnet" "subnet" {
  vpc_id                  = "${var.vpc_id}"
  #cidr_block              = "${element(var.cidrs, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  #count                   = "${length(var.cidrs)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
  count = "${length(var.azs)}" # "${var.num_of_azs}" # FIX this and rest in module: length(var.azs) ?
  cidr_block = "${cidrsubnet(var.cidr_block, var.cidr_add_bits, var.subnet_offset + count.index)}"

/* Vars needed: cidr_block (lookup from aws_vpc.${environment}.cidr_block ?), cidr_add_bits, subnet_offset
  count = "${lookup(var.num_of_azs, var.env)}"
  vpc_id = "${aws_vpc.vpc.id}"
  # public
  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index)}"
  availability_zone = "${format("%s%s", var.aws_region, element(var.preferred_azs[format("%s.%s", var.env, var.aws_region)], count.index))}"
  # private
  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, var.cidr_add_bits, var.subnet_offset + count.index)}"
  availability_zone = "${element(aws_subnet.subnets_public.*.availability_zone, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "subnet-${var.env}-public-${count.index}"
  }
  */
  lifecycle {
    create_before_destroy = true
  }
  #tags = "${merge(var.tags, map("Name", format("%s.%s", var.name, element(var.azs, count.index))))}"
  # Define: Name, Environment
  #map("Name", format("%s.%s", var.name, element(var.azs, count.index)))
  tags = "${ merge(
    var.tags,
    map("Name", var.namespaced ?
     format("%s-%s-%03d", var.environment, var.name, count.index+1) :
     format("%s-%03d", var.name, count.index+1) ),
    map("Environment", var.environment),
    map("Terraform", "true") )}"
}

# Routes
resource "aws_route_table" "subnet" {
  vpc_id = "${var.vpc_id}"
  count  = "${length(var.azs)}"
  propagating_vgws = ["${var.propagate_vgws}"]
/*
vpc_id = "${aws_vpc.vpc.id}"
count = "${lookup(var.num_of_azs, var.env)}" # private
propagating_vgws = [ "${aws_vpn_gateway.vgw_corp.id}" ]
tags {
  Name = "rtb-${var.env}-public"
}
*/
  tags = "${ merge(
    var.tags,
    map("Name", var.namespaced ?
      format("%s-%s-%s", var.environment, var.name, element(var.azs, count.index)) :
      format("%s-%s", var.name, element(var.azs, count.index)) ),
    map("Environment", var.environment),
    map("Terraform", "true") )}"
}

resource "aws_route_table_association" "subnet" {
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.subnet.*.id, count.index)}"
  count          = "${length(var.azs)}"
/*
count = "${lookup(var.num_of_azs, var.env)}"
subnet_id = "${element(aws_subnet.subnets_public.*.id, count.index)}"
route_table_id = "${aws_route_table.rtb_public.id}"
*/
  lifecycle {
    create_before_destroy = true
  }
}
/*
resource "aws_route" "igw" {
  route_table_id         = "${element(aws_route_table.subnet.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${var.igw_id}"
  count                  = "${length(var.azs)}"

  depends_on             = [
    "aws_route_table.subnet"
  ]

  lifecycle {
    create_before_destroy = true
  }
}
*/
