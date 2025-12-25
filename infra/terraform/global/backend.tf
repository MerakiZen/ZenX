terraform {
  backend "s3" {
    bucket = "zenx-terraform-state"
    key    = "global/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "zenx-terraform-lock"
  }
}
