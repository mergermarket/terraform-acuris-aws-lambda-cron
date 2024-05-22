# AWS Lambda Cron Terraform Module

[![Test](https://github.com/mergermarket/terraform-acuris-aws-lambda-cron/actions/workflows/test.yml/badge.svg)](https://github.com/mergermarket/terraform-acuris-aws-lambda-cron/actions/workflows/test.yml)

This module will deploy a Lambda function and a cron rule to run the Lambda function on a schedule.

## Module Input Variables

- `s3_bucket` - (string) - **REQUIRED** - The name of the bucket containing your uploaded Lambda deployment package.
- `s3_key` - (string) - **REQUIRED** - The s3 key for your Lambda deployment package.
- `function_name` - (string) - **REQUIRED** - The name of the Lambda function.
- `handler` - (map) - **REQUIRED** - The function within your code that Lambda calls to begin execution.
- `runtime` - (string) - **REQUIRED** The runtime environment for the Lambda function you are uploading.
- `lambda_cron_schedule` (string) - **REQUIRED** - The scheduling expression. For example, cron(0 20 \* \* ? \*) or rate(5 minutes).
- `subnet_ids` (list) - **REQUIRED** - The ids of VPC subnets to run in.
- `security_group_ids` (list) - **REQUIRED** - The ids of VPC security groups to assign to the Lambda.
- `timeout` (string) - _optional_ - The number of seconds the Lambda will be allowed to run for.
- `lambda_role_policy` (string) - The Lambda IAM Role Policy.
- `lambda_env` - (string) - _optional_ - Environment parameters passed to the Lambda function.
- `tags` (map) - A mapping of tags to assign to this lambda function.
- `architectures (list) - _optional_ - The architectures supported by the Lambda function. Defaults to ["x86_64"].

## Usage

```hcl
module "lambda-function" {
  source                    = "mergermarket/aws-lambda-cron/acuris"
  version                   = "0.0.4"
  s3_bucket                 = "s3_bucket_name"
  s3_key                    = "s3_key_for_lambda"
  function_name             = "do_foo"
  handler                   = "do_foo_handler"
  runtime                   = "nodejs"
  lambda_cron_schedule      = "rate(5 minutes)"
  lambda_env                = "${var.lambda_env}"
  architecture              = ["arm64"]
}
```
Lambda environment variables file:
```json
{
  "lambda_env": {
    "environment_name": "ci-testing"
  }
}
```
