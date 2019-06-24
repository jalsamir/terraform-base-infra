provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "mgmtinfra" {
  source                  = "./mgmtinfra"
  ip_range                = var.ip_range
  mgmt                    = var.mgmt
  pres                    = var.pres
  env                     = var.env
  awsreg                  = var.awsreg
  region                  = var.region
  mgmt_vpc_cidr           = var.mgmt_vpc_cidr
  availability_zones 	  = var.availability_zones
  mgmt_vpc_pub_subnet_ips = var.mgmt_vpc_pub_subnet_ips
  mgmt_vpc_pri_subnet_ips = var.mgmt_vpc_pri_subnet_ips
  mgmt_vpc_ad_subnet_ips  = var.mgmt_vpc_ad_subnet_ips
  vpc_pub_subnet_names    = var.vpc_pub_subnet_names
  vpc_pri_subnet_names    = var.vpc_pri_subnet_names
  vpc_ad_subnet_names     = var.vpc_ad_subnet_names
}

module "presinfra" {
  source                  = "./presinfra"
  accountid				  = var.accountid
  ip_range                = var.ip_range
  mgmt                    = var.mgmt
  pres                    = var.pres
  env                     = var.env
  awsreg                  = var.awsreg
  region                  = var.region
  pres_vpc_cidr           = var.pres_vpc_cidr
  availability_zones 	  = var.availability_zones
  pres_vpc_pub_subnet_ips = var.pres_vpc_pub_subnet_ips
  pres_vpc_web_subnet_ips = var.pres_vpc_web_subnet_ips
  pres_vpc_app_subnet_ips = var.pres_vpc_app_subnet_ips
  pres_vpc_db_subnet_ips  = var.pres_vpc_db_subnet_ips
  vpc_pub_subnet_names    = var.vpc_pub_subnet_names
  vpc_web_subnet_names    = var.vpc_web_subnet_names
  vpc_app_subnet_names    = var.vpc_app_subnet_names
  vpc_db_subnet_names     = var.vpc_db_subnet_names
  mgmt_vpc_id     = "${module.mgmtinfra.mgmt_vpc_id}"
}