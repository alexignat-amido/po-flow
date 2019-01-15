
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

resource "aws_s3_bucket" "logs" {

  bucket = "${var.site_name}-site-logs"
  acl = "log-delivery-write"
}

resource "aws_s3_bucket" "www_site" {

  bucket = "www.${var.site_name}"
  acl    = "public-read"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "www.${var.site_name}/"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_route53_zone" "subdomain" {
  name = "${var.site_name}"
}