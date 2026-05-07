resource "aws_iam_role" "iam_for_lambda" {
  name_prefix = replace(
    replace(var.function_name, "/(.{0,32}).*/", "$1"),
    "/^-+|-+$/",
    "",
  )

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.iam_for_lambda.id
  name = "policy"

  policy = var.lambda_role_policy
}

resource "aws_iam_role_policy_attachment" "vpc_permissions" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"

  count = length(var.subnet_ids) != 0 ? 1 : 0
}

/// Only create policy if using OpenTelemetry Collector, as it will need permissions to read the log subscription ARN from SSM Parameter Store

data "aws_ssm_parameter" "otel_datadog_log_subscription_arn" {
  count = var.enable_otel_collector ? 1 : 0
  
  name = var.otel_datadog_log_subscription_arn_ssm_parameter_name
}

data "aws_iam_policy_document" "otel_collector_policy_document" {
  count = var.enable_otel_collector ? 1 : 0

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]
    resources = [data.aws_ssm_parameter.otel_datadog_log_subscription_arn[0].value]
  }
}

resource "aws_iam_role_policy" "otel_collector_policy" {
  count = var.enable_otel_collector ? 1 : 0
  role = aws_iam_role.iam_for_lambda.id
  name = "otel_collector_policy"
  policy = data.aws_iam_policy_document.otel_collector_policy_document[0].json
}

/// Deny CloudWatch Logs permissions when OpenTelemetry Collector is enabled or logging is disabled

data "aws_iam_policy_document" "deny_cloudwatch_logs" {
  count = var.enable_otel_collector || var.disable_logging ? 1 : 0

  statement {
    effect = "Deny"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy" "deny_cloudwatch_logs" {
  count  = var.enable_otel_collector || var.disable_logging ? 1 : 0
  role   = aws_iam_role.iam_for_lambda.id
  name   = "deny_cloudwatch_logs"
  policy = data.aws_iam_policy_document.deny_cloudwatch_logs[0].json
}