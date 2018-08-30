variable "access_key" {}
variable "secret_key" {}


variable "vpc_name" {
  description = "Name for the VPC"
  default = "Product X Development"
}

variable "vpc_env_type" {
  description = "Environment type for the VPC"
  default = "Development"
}

variable "vpc_env_type_abbr" {
  description = "Environment type abbreviation for the VPC"
  default = "Dev"
}

variable "vpc_region" {
  description = "Region for the VPC"
  default = "us-east-2"
}

variable "vpc_cidr" {
  type = "map"
  default = {
    "us-east-2" = "172.27.0.0/16"
    "us-west-2" = "172.28.0.0/16"
  }
}

variable "vpc_azs" {
    type = "map"
    default = {
        "us-east-2" = "us-east-2a,us-east-2b,us-east-2c"
        "us-west-2" = "us-west-2a,us-west-2b,us-west-2c"
    }
}

variable "vpc_public_subnets" {
  type = "map"
  default = {
    "us-east-2" = "172.27.11.0/24,172.27.12.0/24,172.27.13.0/24"
    "us-west-2" = "172.28.11.0/24,172.28.12.0/24,172.28.13.0/24"
  }
}

variable "vpc_app_subnets" {
  type = "map"
  default = {
    "us-east-2" = "172.27.21.0/24,172.27.22.0/24,172.27.23.0/24"
    "us-west-2" = "172.28.21.0/24,172.28.22.0/24,172.28.23.0/24"
  }
}

variable "vpc_data_subnets" {
  type = "map"
  default = {
    "us-east-2" = "172.27.31.0/24,172.27.32.0/24,172.27.33.0/24"
    "us-west-2" = "172.28.31.0/24,172.28.32.0/24,172.28.33.0/24"
  }
}

variable "vpc_instance_tenancy" {
  default = "default"
}

variable "vpc_enable_dns_resolution" {
  default = "true"
}

variable "vpc_enable_dns_hostnames" {
  default = "true"
}

