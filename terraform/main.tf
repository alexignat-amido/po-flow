
terraform {
  backend "s3" {
    bucket = "abw-po-flow-terraform-state"
    key = "state/"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "${var.region}"
  version = "1.49.0"
}

resource "aws_s3_bucket" "default" {
  bucket = "po-flow"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}