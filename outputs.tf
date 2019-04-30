output "lambda_arn" {
  value = "${module.lambda.lambda_arn}"
}

output "lambda_iam_role_name" {
  value = "${aws_iam_role.iam_for_lambda.name}"
}
