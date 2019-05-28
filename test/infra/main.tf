provider "aws" {
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_get_ec2_platforms      = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  max_retries                 = 1
  access_key                  = "a"
  secret_key                  = "a"
  region                      = "eu-west-1"
}

module "lambda" {
  source               = "../.."
  s3_bucket            = "cdflow-lambda-releases"
  s3_key               = "s3key.zip"
  function_name        = "check_lambda_function"
  handler              = "some_handler"
  runtime              = "python2.7"
  lambda_env           = "${var.lambda_env}"
  lambda_cron_schedule = "rate(5 minutes)"

  subnet_ids         = "${var.subnet_ids}"
  security_group_ids = "${var.security_group_ids}"
}

module "lambda_long_name" {
  source               = "../.."
  s3_bucket            = "cdflow-lambda-releases"
  s3_key               = "s3key.zip"
  function_name        = "check_lambda_function_with_a_really_long_name_should_be_truncated"
  handler              = "some_handler"
  runtime              = "python2.7"
  lambda_env           = "${var.lambda_env}"
  lambda_cron_schedule = "rate(5 minutes)"

  subnet_ids         = "${var.subnet_ids}"
  security_group_ids = "${var.security_group_ids}"
}

variable "subnet_ids" {
  type        = "list"
  description = "The VPC subnets in which the Lambda runs"
  default     = []
}

variable "security_group_ids" {
  type        = "list"
  description = "The VPC security groups assigned to the Lambda"
  default     = []
}

variable "lambda_env" {
  description = "Environment parameters passed to the Lambda function"
  type        = "map"
  default     = {}
}

output "lambda_function_arn" {
  value = "${module.lambda.lambda_arn}"
}
