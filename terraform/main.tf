provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "lamba_export" {
  function_name = "rds-snapshot-to-s3-go"
  description   = "[Terraform] Function to export rds snapshot to S3 bucket."
  handler       = "main"
  role          = aws_iam_role.role_lambda.arn
  runtime       = "go1.x"
  filename      = "lambda-function.zip"
}

resource "aws_kms_key" "encript_key" {
  description             = "[Terraform] Key to rds snapshots on S3."
  deletion_window_in_days = 7
  policy                  = <<EOF
{
    "Id": "key-snapshot-rds",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.role_lambda.arn}"
            },
            "Action": [
                "kms:Encrypt",
                "kms:DescribeKey",
                "kms:CreateGrant",
                "kms:ListGrants"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_kms_alias" "encript_key_alias" {
  name          = "alias/rds_snapshot_s3"
  target_key_id = aws_kms_key.encript_key.key_id
}