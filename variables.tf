// Required Variables
variable "s3_bucket" {
  description = "The name of the bucket containing your uploaded Lambda deployment package."
}

variable "s3_key" {
  description = "The s3 key for your Lambda deployment package."
}

variable "function_name" {
  description = "The name of the Lambda function."
}

variable "handler" {
  description = "The function within your code that Lambda calls to begin execution."
}

variable "runtime" {
  description = "The runtime environment for the Lambda function you are uploading."
}

variable "lambda_cron_schedule" {
  description = "The sceduling expression for how often the Lambda function runs."
}

// Optional Variables
variable "subnet_ids" {
  type        = list(string)
  description = "The VPC subnets in which the Lambda runs"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "The VPC security groups assigned to the Lambda"
  default     = []
}

variable "datadog_log_subscription_arn" {
  description = "Log subscription arn for shipping logs to datadog"
  default     = ""
}

variable "lambda_role_policy" {
  description = "The Lambda IAM Role Policy."

  default = <<END
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
END

}

variable "timeout" {
  description = "The maximum time in seconds that the Lambda can run for"
  default     = 3
}

variable "memory_size" {
  description = "The memory in Gb that the function can use"
  default     = 128
}

variable "lambda_env" {
  description = "Environment parameters passed to the Lambda function."
  type        = map(string)
  default     = {}
}

variable "lambda_iam_policy_name" {
  description = "[DEPRECATED] The name for the Lambda functions IAM policy."
  default     = ""
}

variable "is_enabled" {
  description = "Whether the rule should be enabled. (Defaults to True)"
  default     = true
}

variable "layer" {
  description = "Layer ARN - needs to include the version number"
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to this lambda function."
  type        = map(string)
  default     = {}
}

variable "architectures" {
  type = list(string)
  description = "The architectures supported by the Lambda function."
  default = ["x86_64"]  
}

variable "vpc_id" {
  description = "The VPC ID in which the Lambda runs"
  default     = ""
}

variable "use_default_security_group" {
  type = bool
  description = "Whether to use the default security group for the Lambda function."
  default = false
}