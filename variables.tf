variable "access_key" {
}

variable "secret_key" {
}

variable "region" {
}

variable "env" {
}

variable "mgmt" {
}

variable "pres" {
}

variable "key_name" {
}

variable "ip_range" {
}
variable "accountid" {
  type = map
  default = {
    "PreProd" = "var.preprodacc"
    "Prod" = "var.prodacc"
  }
}
variable "awsreg" {
  type = map
  default = {
    "eu-west-1" = "EU-W1"
    "eu-west-2" = "EU-W2"
  }
}

variable "availability_zones" {
  type = map
  default = {
    "eu-west-1" = ["eu-west-1a", "eu-west-1b"]
    "eu-west-2" = ["eu-west-2b", "eu-west-2b"]
  }
}
###### Variables for Base Infrastructure 

variable "mgmt_vpc_cidr" {
  type = map
  default = {
    "eu-west-1" = {
      "PreProd" = "192.168.11.0/24"
      "Prod"    = "192.168.12.0/24"
    }
    "eu-west-2" = {
      "PreProd" = "192.168.15.0/24"
      "Prod"    = "192.168.16.0/24"
    }
  }
}
variable "mgmt_vpc_pub_subnet_ips" {
  type = map
  default = {
    "eu-west-1" = {
      "PreProd" = ["192.168.11.0/27", "192.168.11.32/27"]
      "Prod"    = ["192.168.12.0/27", "192.168.12.32/27"]
    }
    "eu-west-2" = {
      "PreProd" = ["192.168.15.0/27", "192.168.15.32/27"]
      "Prod"    = ["192.168.16.0/27", "192.168.16.32/27"]
    }
  }
}

variable "mgmt_vpc_pri_subnet_ips" {
  type = map
  default = {
    "eu-west-1" = {
      "PreProd" = ["192.168.11.64/27", "192.168.11.96/27"]
      "Prod"    = ["192.168.12.64/27", "192.168.12.96/27"]
    }
    "eu-west-2" = {
      "PreProd" = ["192.168.15.64/27", "192.168.15.96/27"]
      "Prod"    = ["192.168.16.64/27", "192.168.16.96/27"]
    }
  }
}

variable "mgmt_vpc_ad_subnet_ips" {
  type = map
  default = {
    "eu-west-1" = {
      "PreProd" = ["192.168.11.128/27", "192.168.11.160/27"]
      Prod      = ["192.168.12.128/27", "192.168.12.160/27"]
    }
    "eu-west-2" = {
      "PreProd" = ["192.168.15.128/27", "192.168.15.160/27"]
      "Prod"    = ["192.168.16.128/27", "192.168.16.160/27"]
    }
  }
}

variable "vpc_pub_subnet_names" {
  default = ["Pub-Sub-A", "Pub-Sub-B"]
}

variable "vpc_pri_subnet_names" {
  default = ["Pri-Sub-A", "Pri-Sub-B"]
}

variable "vpc_ad_subnet_names" {
  default = ["AD-Sub-A", "AD-Sub-B"]
}
############################################################################

variable "vpc_web_subnet_names" {
  default = ["Web-Sub-A", "Web-Sub-B"]
}

variable "vpc_app_subnet_names" {
  default = ["App-Sub-A", "App-Sub-B"]
}

variable "vpc_db_subnet_names" {
  default = ["DB-Sub-A", "DB-Sub-B"]
}
variable "pres_vpc_cidr" {
  type = map
  default = {
    "eu-west-1" = {
      "PreProd" = "192.168.13.0/24"
      "Prod"    = "192.168.14.0/24"
    }
    "eu-west-2" = {
      "PreProd" = "192.168.17.0/24"
      "Prod"    = "192.168.18.0/24"
    }
  }
}
variable "pres_vpc_pub_subnet_ips" {
  type = map
  default = {
    "eu-west-1" = {
      "PreProd" = ["192.168.13.0/27", "192.168.13.32/27"]
      "Prod"    = ["192.168.14.0/27", "192.168.14.32/27"]
    }
    "eu-west-2" = {
      "PreProd" = ["192.168.17.0/27", "192.168.17.32/27"]
      "Prod"    = ["192.168.18.0/27", "192.168.18.32/27"]
    }
  }
}

variable "pres_vpc_web_subnet_ips" {
  type = map
  default = {
    "eu-west-1" = {
      "PreProd" = ["192.168.13.64/27", "192.168.13.96/27"]
      "Prod"    = ["192.168.14.64/27", "192.168.14.96/27"]
    }
    "eu-west-2" = {
      "PreProd" = ["192.168.17.64/27", "192.168.17.96/27"]
      "Prod"    = ["192.168.18.64/27", "192.168.18.96/27"]
    }
  }
}

variable "pres_vpc_app_subnet_ips" {
  type = map
  default = {
    "eu-west-1" = {
      "PreProd" = ["192.168.13.128/27", "192.168.13.160/27"]
      Prod      = ["192.168.14.128/27", "192.168.14.160/27"]
    }
    "eu-west-2" = {
      "PreProd" = ["192.168.17.128/27", "192.168.17.160/27"]
      "Prod"    = ["192.168.18.128/27", "192.168.18.160/27"]
    }
  }
}

variable "pres_vpc_db_subnet_ips" {
  type = map
  default = {
    "eu-west-1" = {
      "PreProd" = ["192.168.13.192/27", "192.168.13.224/27"]
      Prod      = ["192.168.14.192/27", "192.168.14.224/27"]
    }
    "eu-west-2" = {
      "PreProd" = ["192.168.17.192/27", "192.168.17.224/27"]
      "Prod"    = ["192.168.18.192/27", "192.168.18.224/27"]
    }
  }
}