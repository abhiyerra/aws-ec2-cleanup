resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
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

resource "aws_sns_topic" "ec2_cleanup" {
  name = "ec2_cleanup"
}

resource "aws_lambda_function" "opszero_lambda" {
  filename = "output.zip"
  function_name = "opszero_mailing_list"
  role = "${aws_iam_role.iam_for_lambda.arn}"
  handler = "index.handler"
  source_code_hash = "${base64sha256(file("output.zip"))}"
}

resource "aws_sns_topic_subscription" "ec2_cleanup_subscription" {
  depends_on = ["aws_lambda_function.opszero_lambda"]
  topic_arn = "${aws_sns_topic.ec2_cleanup.arn}"
  protocol = "lambda"
  endpoint = "${aws_lambda_function.opszero_lambda.arn}"
}
