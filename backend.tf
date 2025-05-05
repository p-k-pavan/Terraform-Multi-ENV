terraform {
  backend "s3" {
    bucket = ""
    key    = "global/s3/terraform.tfstate"
    region = "ap-south-1"
  }
}