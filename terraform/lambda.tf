variable "function_name" {
  default = "fk_acclaim_302"
}

data "archive_file" "fk_acclaim_redirect" {
  type        = "zip"
  source_file = "../src/lambda/fk-redirect.js"
  output_path = "./dist/lambda_function.zip"
}

resource "aws_lambda_function" "redirect_lambda" {
  filename         = "lambda_function.zip"
  function_name    = var.function_name
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "redirect.handler"
  source_code_hash = "${data.archive_file.fk_acclaim_redirect.output_base64sha256}"
  runtime          = "nodejs14.x"
}

