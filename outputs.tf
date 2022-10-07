# TODO: Define the output variable for the lambda function.
output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = join("", aws_lambda_function.terraform_lambda_func.*.arn)
}