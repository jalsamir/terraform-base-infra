/*
resource "null_resource" "example1" {
  # ...

  provisioner "local-exec" {

  
    command = "echo   "${var.accountid[var.env]}"}
  }

*/
### Create VPC

resource "aws_vpc" "mgmt_vpc" {
  cidr_block = "${lookup(var.mgmt_vpc_cidr[var.region],var.env)}"
  enable_dns_hostnames = true
  tags =  {
      Name = join("-", [var.awsreg[var.region], var.env, var.mgmt , "VPC"])
      Env = var.env
  }
}

output "mgmt_vpc_id" {
  value = "${aws_vpc.mgmt_vpc.id}"
}

resource "aws_cloudwatch_log_group" "mgmt_vpc" {
  name = "${var.awsreg[var.region]}-${var.env}-${var.mgmt}-VPC-Logs"
}

resource "aws_iam_role" "mgmt_vpc_role" {
  name = join("-", [var.awsreg[var.region], var.env, var.pres , "VPC-Role"])

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "vpc-flow-logs.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "mgmt_vpc_log" {
  name = "${var.awsreg[var.region]}-${var.env}-${var.mgmt}-VPC-Log-Policy"
  role = "${aws_iam_role.mgmt_vpc_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
}
  EOF
}

resource "aws_flow_log" "mgmt_vpc_flologs" {
  iam_role_arn    = "${aws_iam_role.mgmt_vpc_role.arn}"
  log_destination = "${aws_cloudwatch_log_group.mgmt_vpc.arn}"
  traffic_type    = "ALL"
  vpc_id          = "${aws_vpc.mgmt_vpc.id}"
}

### Create Internet Gateway

resource "aws_internet_gateway" "mgmt_igw" {
  vpc_id = "${aws_vpc.mgmt_vpc.id}"
  tags = {
      Name = join("-", [var.awsreg[var.region], var.env, var.mgmt , "IGW"])
	  Env = var.env
  }
}


### Create Public Subnets

resource "aws_subnet" "mgmt_public_subnets" {
  count             = "${length(var.mgmt_vpc_pub_subnet_ips[var.region][var.env])}"
  vpc_id            = "${aws_vpc.mgmt_vpc.id}"
  cidr_block        = "${element(var.mgmt_vpc_pub_subnet_ips[var.region][var.env], count.index)}"
  availability_zone = "${element(var.availability_zones[var.region], count.index)}"
  depends_on = ["aws_vpc.mgmt_vpc"]
  tags = {
    Name = join("-", [var.awsreg[var.region]], [var.env], [var.mgmt], [element(var.vpc_pub_subnet_names, count.index)])
	Env = var.env
    }
}
output "mgmt_public_subnets_id" {
  value = ["${aws_subnet.mgmt_public_subnets.*.id}"]
}

### Create Public Route Table
resource "aws_route_table" "mgmt_public_route_table" {
  vpc_id = "${aws_vpc.mgmt_vpc.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.mgmt_igw.id}"
  }
  tags = {
      Name = join("-", [var.awsreg[var.region], var.env, var.mgmt , "PublicRouteTable"])
	  Env = var.env
  }
}
output "mgmt_public_route" {
  value = "${aws_route_table.mgmt_public_route_table.id}"
}
resource "aws_route_table_association" "mgmt_public_subnets" {
  count          = "${length(var.mgmt_vpc_pub_subnet_ips[var.region])}"
  subnet_id      = "${element(aws_subnet.mgmt_public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.mgmt_public_route_table.id}"
}



### Create Private Subnets

resource "aws_subnet" "mgmt_private_subnets" {
  count             = "${length(var.mgmt_vpc_pri_subnet_ips[var.region][var.env])}" 
  vpc_id            = "${aws_vpc.mgmt_vpc.id}"
  cidr_block        = "${element(var.mgmt_vpc_pri_subnet_ips[var.region][var.env], count.index)}"
  availability_zone = "${element(var.availability_zones[var.region], count.index)}"
  depends_on = ["aws_vpc.mgmt_vpc"]
  tags = {
    Name = join("-", [var.awsreg[var.region]], [var.env], [var.mgmt], [element(var.vpc_pri_subnet_names, count.index)])
	Env = var.env
  }
}
output "mgmt_private_subnets_id" {
  value = ["${aws_subnet.mgmt_private_subnets.*.id}"]
}

resource "aws_subnet" "mgmt_ad_subnets" {
  count             = "${length(var.mgmt_vpc_ad_subnet_ips[var.region][var.env])}"
  vpc_id            = "${aws_vpc.mgmt_vpc.id}"
  cidr_block        = "${element(var.mgmt_vpc_ad_subnet_ips[var.region][var.env], count.index)}"
  availability_zone = "${element(var.availability_zones[var.region], count.index)}"
  depends_on = ["aws_vpc.mgmt_vpc"]
  tags = { 
    Name = join("-", [var.awsreg[var.region]], [var.env], [var.mgmt], [element(var.vpc_ad_subnet_names, count.index)])
	Env = var.env
  } 
}
output "mgmt_ad_subnets_id" {
  value = ["${aws_subnet.mgmt_ad_subnets.*.id}"]
}
###### Create Nat Gateway
resource "aws_eip" "mgmt_natip" {
  vpc      = true
}
resource "aws_nat_gateway" "mgmt_ngw" {
  allocation_id = "${aws_eip.mgmt_natip.id}"
  subnet_id     = "${element(aws_subnet.mgmt_public_subnets.*.id, 0)}"
  depends_on = ["aws_internet_gateway.mgmt_igw"]

  tags = {
    Name = join("-", [var.awsreg[var.region], var.env, var.mgmt , "NatGW"])
	Env = var.env
  }
}

### Create Private Route Table
resource "aws_route_table" "mgmt_private_route_table" {
  vpc_id = "${aws_vpc.mgmt_vpc.id}"
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${aws_nat_gateway.mgmt_ngw.id}"
  } 
  tags = { 
      Name = join("-", [var.awsreg[var.region], var.env, var.mgmt , "PrivateRouteTable"])
	  Env = var.env
  } 
} 
output "mgmt_private_route" {
  value = "${aws_route_table.mgmt_private_route_table.id}"
}
resource "aws_route_table_association" "private_subnets" {
  count          = "${length(var.mgmt_vpc_pri_subnet_ips[var.region])}"
  subnet_id      = "${element(aws_subnet.mgmt_private_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.mgmt_private_route_table.id}"
}
resource "aws_route_table_association" "ad_subnets" {
  count          = "${length(var.mgmt_vpc_ad_subnet_ips[var.region])}"
  subnet_id      = "${element(aws_subnet.mgmt_ad_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.mgmt_private_route_table.id}"
}
# Network ACLs
### Create public nacl
resource "aws_network_acl" "mgmt_pub-nacl" {
  vpc_id  = "${aws_vpc.mgmt_vpc.id}"
  subnet_ids      = "${aws_subnet.mgmt_public_subnets.*.id}"
  tags = {
      Name = join("-", [var.awsreg[var.region], var.env, var.mgmt , "Pub-Nacl"])
	  Env = var.env
  }
  ingress  {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }
  ingress  {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }

  ingress  {
    protocol = "tcp"
    rule_no = 130
    action = "allow"
    cidr_block =  "${var.ip_range}"
    from_port = 22
    to_port = 22
  }
  ingress  {
    protocol = "tcp"
    rule_no = 140
    action = "allow"
    cidr_block =  "${var.ip_range}"
    from_port = 3389
    to_port = 3389
  }
  ingress  {
    protocol = "tcp"
    rule_no = 150
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  egress  {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "${var.mgmt_vpc_cidr[var.region][var.env]}"  
    from_port = 53
    to_port = 53
  }
  egress  {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }

  egress  {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }

  egress  {
    protocol = "tcp"
    rule_no = 130
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }
}
### Create Private nacl

resource "aws_network_acl" "pri-nacl" {
  vpc_id  = "${aws_vpc.mgmt_vpc.id}"
  subnet_ids      = "${aws_subnet.mgmt_private_subnets.*.id}"
    tags = {
      Name = join("-", [var.awsreg[var.region], var.env, var.mgmt , "Pri-Nacl"])
	  Env = var.env
  }
  ingress  {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }
  ingress  {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }
  ingress  {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block =  "${var.ip_range}"
    from_port = 22
    to_port = 22
  }
  ingress  {
    protocol = "tcp"
    rule_no = 130
    action = "allow"
    cidr_block =  "${var.ip_range}"
    from_port = 3389
    to_port = 3389
  }
  ingress  {
    protocol = "tcp"
    rule_no = 140
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  egress  {
    protocol = "udp"
    rule_no = 100
    action = "allow"
    cidr_block = "${var.mgmt_vpc_cidr[var.region][var.env]}"  
    from_port = 53
    to_port = 53
  }
  egress  {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }

  egress  {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }

  egress  {
    protocol = "tcp"
    rule_no = 130
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }
} 
