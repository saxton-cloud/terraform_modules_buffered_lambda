locals {
  qualified_name = "${var.product_code}-${var.qualifier}-${var.subsystem}-${var.name}"
  account_id     = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
