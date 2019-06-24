variable "accountid" {type = "map"}
variable "ip_range" {}
variable "region" {}
variable "env" {}
variable "mgmt" {}
variable "pres" {}
variable "awsreg" {type = "map"}
variable "pres_vpc_cidr" {type = "map"}
variable "availability_zones" {type = "map"}
variable "pres_vpc_pub_subnet_ips" {type = "map"}
variable "pres_vpc_web_subnet_ips" {type = "map"}
variable "pres_vpc_app_subnet_ips" {type = "map"}
variable "pres_vpc_db_subnet_ips" {type = "map"}
variable "vpc_pub_subnet_names" {type = "list"}
variable "vpc_web_subnet_names" {type = "list"}
variable "vpc_app_subnet_names" {type = "list"}
variable "vpc_db_subnet_names" {type = "list"}
variable "mgmt_vpc_id" {}
