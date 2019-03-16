variable "region" {
  default = "eu-west-2"
}

provider "aws" {
  region = "${var.region}"
}


# VPC
resource "aws_vpc" "k8s-vpc" {
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
  vpc_id          = "${aws_vpc.k8s-vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.k8s.id}"
}


# Subnet
resource "aws_subnet" "k8s" {
  vpc_id     = "${aws_vpc.k8s-vpc.id}"
  cidr_block = "10.240.0.0/24"

  tags {
    Name = "kubernetes"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "k8s" {
  vpc_id = "${aws_vpc.k8s-vpc.id}"

  tags = {
    Name = "kubernetes"
  }
}

# Route table
resource "aws_route_table" "k8s" {
  vpc_id = "${aws_vpc.k8s-vpc.id}"

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

  vpc_id = "${aws_vpc.k8s-vpc.id}"

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

  # should allow incoming ICMP echo "ping" requests
  ingress {
    from_port = 0
    to_port = 8 # ICMP code if protocol is "icmp"
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kubernetes"
  }
}

# Public IP Address
resource "aws_lb" "k8s-lb" {
  name = "kubernetes-lb"
  subnets = ["${aws_subnet.k8s.id}"]
  internal = false
  load_balancer_type = "network"
}

resource "aws_lb_target_group" "k8s-lb-tg" {
  name = "kubernetes-lb-tg"
  protocol = "TCP"
  port = 6443
  vpc_id = "${aws_vpc.k8s-vpc.id}"
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "k8s" {
  count = "${length(var.instance_ips)}"
  target_group_arn = "${aws_lb_target_group.k8s-lb-tg.arn}"
  target_id        = "${var.instance_ips[count.index]}"
}

# temp instance required to set up target for lb
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["self"]
}

resource "aws_instance" "k8s-ec2" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
}

# move to separat variables file
variable "instance_ips" {
  type = "list"

  default = [
    "10.240.0.10"
  ]
}

resource "aws_lb_listener" "k8s" {
  load_balancer_arn = "${aws_lb.k8s-lb.arn}"
  protocol = "TCP"
  port = "6443"
  
  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.k8s-lb-tg.arn}"
  }
}
