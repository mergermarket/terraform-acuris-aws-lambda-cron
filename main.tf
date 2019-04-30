module "lambda" {
  source                       = "mergermarket/aws-lambda/acuris"
  version                      = "0.0.3"
  s3_bucket     = "${var.s3_bucket}"
  s3_key        = "${var.s3_key}"
  function_name = "${var.function_name}"
  handler                      = "${var.handler}"
  runtime                      = "${var.runtime}"
  timeout                      = "${var.timeout}"
  datadog_log_subscription_arn = "${var.datadog_log_subscription_arn}"
  memory_size                  = "${var.memory_size}"
  lambda_env                   = "${var.lambda_env}"
  subnet_ids                   = "${var.subnet_ids}"
  security_group_ids           = "${var.security_group_ids}"
}

resource "aws_cloudwatch_event_rule" "cron_schedule" {
  name                = "${replace("${var.function_name}-cron_schedule", "/(.{0,64}).*/", "$1")}"
  description         = "This event will run according to a schedule for Lambda ${var.function_name}"
  schedule_expression = "${var.lambda_cron_schedule}"
  is_enabled          = "${var.is_enabled}"
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule = "${aws_cloudwatch_event_rule.cron_schedule.name}"
  arn  = "${module.lambda.lambda_arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda.lambda_function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.cron_schedule.arn}"
}
