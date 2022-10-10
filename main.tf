# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-east-1"
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "Udacity_t2s" {
  count = "4"
  ami = "ami-0323c3dd2da7fb37d"
  subnet_id = "subnet-0242abe8be2ce7d2c"
  instance_type = "t2.micro"
  tags = {
    name = "Udacity T2",
    Name = "Udacity_t2-${count.index +1}"
  }
}


resource "aws_iam_role" "lambda_role" {
name   = "Udacity_Lambda_Function_Role"
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


resource "aws_iam_policy" "iam_policy_for_lambda" {
 
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}






resource "aws_cloudwatch_log_group" "function_log_group" {
  name = "/aws/lambda/aws_lambda_function.lambda_handler"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}



data "archive_file" "zip_the_python_code" {
    type        = "zip"
    source_dir  = "./python/"
    output_path = "hello-python.zip"
}


resource "aws_lambda_function" "terraform_lambda_func" {
    filename                       = "hello-python.zip"
    function_name                  = "lambda_handler"
    role                           = aws_iam_role.lambda_role.arn
    handler                        = "greet_lambda.lambda_handler"
    runtime                        = "python3.8"
    depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]    

  environment {
    variables = {
      greeting = "${var.greeting}"
    }
  }
}
