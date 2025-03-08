terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "c2devel/rockitcloud"
      version = "24.1.0"
    }
  }
}

provider "aws" {
  region                      = ""
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  endpoints {
    ec2 = "https://ec2.k2.cloud"
    s3  = "https://s3.k2.cloud"
  }
}
