terraform {
  backend "s3" {
    bucket                    = "tf-state"
    region                    = "eu-frankfurt-1"
    key                       = "homelab.tfstate"
    profile                   = "OCI"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    use_path_style              = true
    skip_s3_checksum            = true
    skip_metadata_api_check = true
    endpoints = {
      s3 = "https://frp5iehuhoet.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
    }
  }
}