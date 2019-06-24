variable "ip_range" {}
variable "region" {}
variable "env" {}
variable "mgmt" {}
variable "pres" {}
variable "awsreg" {type = "map"}
variable "mgmt_vpc_cidr" {type = "map"}
variable "availability_zones" {type = "map"}
variable "mgmt_vpc_pub_subnet_ips" {type = "map"}
variable "mgmt_vpc_pri_subnet_ips" {type = "map"}
variable "mgmt_vpc_ad_subnet_ips" {type = "map"}
variable "vpc_pub_subnet_names" {type = "list"}
variable "vpc_pri_subnet_names" {type = "list"}
variable "vpc_ad_subnet_names" {type = "list"}
