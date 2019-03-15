variable "region" {
  default = "eu-west-2"
}

provider "aws" {
  region = "${var.region}"
}


# VPC
resource "aws_vpc" "k8s" {
  cidr_block = "10.240.0.0/24"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "kubernetes-the-hard-way"
  }
}


# DHCP Option Sets
resource "aws_vpc_dhcp_options" "k8s" {
  domain_name = "${var.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "kubernetes"
  }
}

resource "aws_vpc_dhcp_options_association" "k8s" {
  vpc_id          = "${aws_vpc.k8s.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.k8s.id}"
}


# Subnet
resource "aws_subnet" "k8s" {
  vpc_id     = "${aws_vpc.k8s.id}"
  cidr_block = "10.240.0.0/24"

  tags {
    Name = "kubernetes"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "k8s" {
  vpc_id = "${aws_vpc.k8s.id}"

  tags = {
    Name = "kubernetes"
  }
}

# Route table
resource "aws_route_table" "k8s" {
  vpc_id = "${aws_vpc.k8s.id}"

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.k8s.id}"
  }

  tags = {
    Name = "kubernetes"
  }
}

resource "aws_route_table_association" "k8s" {
  subnet_id = "${aws_subnet.k8s.id}"
  route_table_id = "${aws_route_table.k8s.id}"
}

# Security Groups
resource "aws_security_group" "k8s" {
  name = "kubernetes"
  description = "Kubernetes security group"

  vpc_id = "${aws_vpc.k8s.id}"

  # internal
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.240.0.0/24", "10.200.0.0/16"]
  }

  # external SSH, ICMP, and HTTPS
  ingress {
    from_port = 0
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kubernetes"
  }

}