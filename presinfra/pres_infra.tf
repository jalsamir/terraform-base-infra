/*
resource "null_resource" "example1" {
  # ...
  count             = "${length(var.pres_vpc_pub_subnet_ips[var.region][var.env])}"
  provisioner "local-exec" {

  
    command = "echo   ${var.awsreg[var.region]}-${var.env}-${var.pres}-${element(var.vpc_pub_subnet_names, count.index)}
  }
}
*/
### Create VPC

resource "aws_vpc" "pres_vpc" {
  cidr_block = "${lookup(var.pres_vpc_cidr[var.region],var.env)}"
  enable_dns_hostnames = true
  tags =  {
      Name = join("-", [var.awsreg[var.region], var.env, var.pres , "VPC"])
      Env = var.env
  }
}

output "pres_vpc_id" {
  value = "${aws_vpc.pres_vpc.id}"
}

resource "aws_cloudwatch_log_group" "pres_vpc" {
  name = "${var.awsreg[var.region]}-${var.env}-${var.pres}-VPC-Logs"
}

resource "aws_iam_role" "pres_vpc_role" {
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

resource "aws_iam_role_policy" "pres_vpc_log" {
  name = "${var.awsreg[var.region]}-${var.env}-${var.pres}-VPC-Log-Policy"
  role = "${aws_iam_role.pres_vpc_role.id}"

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

resource "aws_flow_log" "pres_vpc_flologs" {
  iam_role_arn    = "${aws_iam_role.pres_vpc_role.arn}"
  log_destination = "${aws_cloudwatch_log_group.pres_vpc.arn}"
  traffic_type    = "ALL"
  vpc_id          = "${aws_vpc.pres_vpc.id}"
}

### Create Internet Gateway

resource "aws_internet_gateway" "pres_igw" {
  vpc_id = "${aws_vpc.pres_vpc.id}"
  tags = {
      Name = join("-", [var.awsreg[var.region], var.env, var.pres , "IGW"])
	  Env = var.env
  }
}


### Create Public Subnets

resource "aws_subnet" "pres_public_subnets" {
  count             = "${length(var.pres_vpc_pub_subnet_ips[var.region][var.env])}"
  vpc_id            = "${aws_vpc.pres_vpc.id}"
  cidr_block        = "${element(var.pres_vpc_pub_subnet_ips[var.region][var.env], count.index)}"
  availability_zone = "${element(var.availability_zones[var.region], count.index)}"
  depends_on = ["aws_vpc.pres_vpc"]
  tags = {
    Name = join("-", [var.awsreg[var.region]], [var.env], [var.pres], [element(var.vpc_pub_subnet_names, count.index)])
    Env = var.env
	}
}
output "pres_public_subnets_id" {
  value = ["${aws_subnet.pres_public_subnets.*.id}"]
}

### Create Public Route Table
resource "aws_route_table" "pres_public_route_table" {
  vpc_id = "${aws_vpc.pres_vpc.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.pres_igw.id}"
  }
  tags = {
      Name = join("-", [var.awsreg[var.region], var.env, var.pres , "PublicRouteTable"])
	  Env = var.env  
  }
}
output "pres_public_route" {
  value = "${aws_route_table.pres_public_route_table.id}"
}
resource "aws_route_table_association" "pres_public_subnets" {
  count          = "${length(var.pres_vpc_pub_subnet_ips[var.region])}"
  subnet_id      = "${element(aws_subnet.pres_public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.pres_public_route_table.id}"
}



### Create Private Subnets

resource "aws_subnet" "pres_web_subnets" {
  count             = "${length(var.pres_vpc_web_subnet_ips[var.region][var.env])}" 
  vpc_id            = "${aws_vpc.pres_vpc.id}"
  cidr_block        = "${element(var.pres_vpc_web_subnet_ips[var.region][var.env], count.index)}"
  availability_zone = "${element(var.availability_zones[var.region], count.index)}"
  depends_on = ["aws_vpc.pres_vpc"]
  tags = {
    Name = join("-", [var.awsreg[var.region]], [var.env], [var.pres], [element(var.vpc_web_subnet_names, count.index)]) 
    Env = var.env
  }
}
output "pres_web_subnets_id" {
  value = ["${aws_subnet.pres_web_subnets.*.id}"]
}

resource "aws_subnet" "pres_app_subnets" {
  count             = "${length(var.pres_vpc_app_subnet_ips[var.region][var.env])}"
  vpc_id            = "${aws_vpc.pres_vpc.id}"
  cidr_block        = "${element(var.pres_vpc_app_subnet_ips[var.region][var.env], count.index)}"
  availability_zone = "${element(var.availability_zones[var.region], count.index)}"
  depends_on = ["aws_vpc.pres_vpc"]
  tags = { 
    Name = join("-", [var.awsreg[var.region]], [var.env], [var.pres], [element(var.vpc_app_subnet_names, count.index)]) 
    Env = var.env
  }
}
output "pres_app_subnets_id" {
  value = ["${aws_subnet.pres_app_subnets.*.id}"]
}

resource "aws_subnet" "pres_db_subnets" {
  count             = "${length(var.pres_vpc_db_subnet_ips[var.region][var.env])}"
  vpc_id            = "${aws_vpc.pres_vpc.id}"
  cidr_block        = "${element(var.pres_vpc_db_subnet_ips[var.region][var.env], count.index)}"
  availability_zone = "${element(var.availability_zones[var.region], count.index)}"
  depends_on = ["aws_vpc.pres_vpc"]
  tags = { 
    Name = join("-", [var.awsreg[var.region]], [var.env], [var.pres], [element(var.vpc_db_subnet_names, count.index)])
	Env = var.env
  } 
}
output "pres_db_subnets_id" {
  value = ["${aws_subnet.pres_db_subnets.*.id}"]
}
###### Create Nat Gateway
resource "aws_eip" "pres_natip" {
  vpc      = true
}
resource "aws_nat_gateway" "pres_ngw" {
  allocation_id = "${aws_eip.pres_natip.id}"
  subnet_id     = "${element(aws_subnet.pres_public_subnets.*.id, 0)}"
  depends_on = ["aws_internet_gateway.pres_igw"]

  tags = {
    Name = join("-", [var.awsreg[var.region], var.env, var.pres , "NatGW"])
	Env = var.env
  }
}

### Create Private Route Table
resource "aws_route_table" "pres_private_route_table" {
  vpc_id = "${aws_vpc.pres_vpc.id}"
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${aws_nat_gateway.pres_ngw.id}"
  }
  tags = { 
      Name = join("-", [var.awsreg[var.region], var.env, var.pres , "PrivateRouteTable"])
	  Env = var.env
  }
} 
output "pres_private_route" {
  value = "${aws_route_table.pres_private_route_table.id}"
}
resource "aws_route_table_association" "web_subnets" {
  count          = "${length(var.pres_vpc_web_subnet_ips[var.region])}"
  subnet_id      = "${element(aws_subnet.pres_web_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.pres_private_route_table.id}"
}
resource "aws_route_table_association" "app_subnets" {
  count          = "${length(var.pres_vpc_app_subnet_ips[var.region])}"
  subnet_id      = "${element(aws_subnet.pres_app_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.pres_private_route_table.id}"
}
resource "aws_route_table_association" "db_subnets" {
  count          = "${length(var.pres_vpc_db_subnet_ips[var.region])}"
  subnet_id      = "${element(aws_subnet.pres_db_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.pres_private_route_table.id}"
}

# Network ACLs
### Create public nacl
resource "aws_network_acl" "pres_pub-nacl" {
  vpc_id  = "${aws_vpc.pres_vpc.id}"
  subnet_ids      = "${aws_subnet.pres_public_subnets.*.id}"
  tags = {
      Name = join("-", [var.awsreg[var.region], var.env, var.pres , "Pub-Nacl"])
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
    cidr_block = "${var.pres_vpc_cidr[var.region][var.env]}"  
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
  vpc_id  = "${aws_vpc.pres_vpc.id}"
  subnet_ids      = "${aws_subnet.pres_web_subnets.*.id}"
    tags = {
      Name = join("-", [var.awsreg[var.region], var.env, var.pres , "Pri-Nacl"])
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
    cidr_block = "${var.pres_vpc_cidr[var.region][var.env]}"  
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

resource "aws_vpc_peering_connection" "pres-to-mgmt-vpc-peer" {
  peer_owner_id = "${var.accountid[var.env]}"
  peer_vpc_id   = "${aws_vpc.pres_vpc.id}"
  vpc_id        = "${var.mgmt_vpc_id}"
  auto_accept   = true

  tags = {
    Name = join("-", [var.awsreg[var.region], var.env, var.pres , "To-Mgmt-Peer"])
	Env = var.env
  }
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

}