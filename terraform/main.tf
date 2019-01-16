terraform {
  backend "s3" {
    bucket = "abw-po-flow-terraform-state"
    key    = "state/"
    region = "eu-west-2"
  }
}

provider "aws" {
  region  = "${var.region}"
  version = "1.49.0"
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.site_name}-site-logs"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "www_site" {
  bucket = "www.${var.site_name}"
  acl    = "public-read"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "www.${var.site_name}/"
  }

  website {
    redirect_all_requests_to = "${var.site_name}"
  }
}

resource "aws_s3_bucket" "site" {
  bucket = "${var.site_name}"
  acl    = "public-read"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "${var.site_name}/"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = "${aws_s3_bucket.site.id}"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
	"Sid":"PublicReadGetObject",
        "Effect":"Allow",
	  "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.site_name}/*"]
    }]
}
POLICY
}

resource "aws_s3_bucket_policy" "www_site_policy" {
  bucket = "${aws_s3_bucket.www_site.id}"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
	"Sid":"PublicReadGetObject",
        "Effect":"Allow",
	  "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::www.${var.site_name}*"]
    }]
}
POLICY
}
