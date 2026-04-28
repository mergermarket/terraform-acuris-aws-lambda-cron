# AWS Lambda Cron Terraform Module

[![Test](https://github.com/mergermarket/terraform-acuris-aws-lambda-cron/actions/workflows/test.yml/badge.svg)](https://github.com/mergermarket/terraform-acuris-aws-lambda-cron/actions/workflows/test.yml)

This module will deploy a Lambda function and a cron rule to run the Lambda function on a schedule.

## Module Input Variables

### Required

- `s3_bucket` (string) - The name of the bucket containing your uploaded Lambda deployment package.
- `s3_key` (string) - The s3 key for your Lambda deployment package.
- `function_name` (string) - The name of the Lambda function.
- `handler` (string) - The function within your code that Lambda calls to begin execution.
- `runtime` (string) - The runtime environment for the Lambda function you are uploading.
- `lambda_cron_schedule` (string) - The scheduling expression. For example, cron(0 20 \* \* ? \*) or rate(5 minutes).

### Optional

- `subnet_ids` (list(string)) - The VPC subnets in which the Lambda runs. Defaults to `[]`.
- `security_group_ids` (list(string)) - The VPC security groups assigned to the Lambda. Defaults to `[]`.
- `vpc_id` (string) - The VPC ID in which the Lambda runs. Required when `use_default_security_group` is `true`. Defaults to `""`.
- `use_default_security_group` (bool) - Whether to use the default security group for the Lambda function. Defaults to `false`.
- `timeout` (number) - The maximum time in seconds that the Lambda can run for. Defaults to `3`.
- `memory_size` (number) - The memory in MB that the function can use. Defaults to `128`.
- `lambda_role_policy` (string) - The Lambda IAM Role Policy. Defaults to a policy that allows writing to CloudWatch Logs.
- `lambda_env` (map(string)) - Environment parameters passed to the Lambda function. Defaults to `{}`.
- `tags` (map(string)) - A mapping of tags to assign to this lambda function. Defaults to `{}`.
- `architectures` (list(string)) - The architectures supported by the Lambda function. Defaults to `["x86_64"]`.
- `layer` (string) - Layer ARN - needs to include the version number. Defaults to `""`.
- `is_enabled` (bool) - Whether the cron rule should be enabled. Defaults to `true`.
- `datadog_log_subscription_arn` (string) - Log subscription ARN for shipping logs to Datadog. Defaults to `""`.
- `enable_otel_collector` (bool) - Whether to add the OpenTelemetry Collector layer and environment variables to the Lambda function. Defaults to `false`.
- `otel_collector_layer_extension_log_level` (string) - The log level for the OpenTelemetry Collector layer extension. Defaults to `"error"`.
- `disable_logging` (bool) - Disable all logging cloudwatch/ otel. Defaults to `false`.
- `lambda_iam_policy_name` (string) - **DEPRECATED** - The name for the Lambda functions IAM policy. Defaults to `""`.

## Outputs

- `lambda_arn` - The ARN of the Lambda function.
- `lambda_iam_role_name` - The name of the IAM role created for the Lambda function.

## Usage

```hcl
module "lambda-function" {
  source                     = "mergermarket/aws-lambda-cron/acuris"
  s3_bucket                  = "s3_bucket_name"
  s3_key                     = "s3_key_for_lambda"
  function_name              = "do_foo"
  handler                    = "do_foo_handler"
  runtime                    = "nodejs"
  lambda_cron_schedule       = "rate(5 minutes)"
  lambda_env                 = var.lambda_env
  architectures              = ["arm64"]
  vpc_id                     = module.platform_config.config["vpc"]
  use_default_security_group = true
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
