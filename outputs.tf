output "lambda_arn" {
  value = "${module.lambda.lambda_arn}"
}

output "lambda_iam_role_name" {
  value = "${module.lambda.lambda_iam_role_name}"
}
