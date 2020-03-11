resource "aws_iam_policy" "policy_export" {
  name        = "AllowManagementS3RdsSnapshot"
  description = "[Terraform] Allow access to s3 bucket of rds snapshots"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:GetBucketLocation",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}",
                "arn:aws:s3:::${var.bucket_name}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "role_export" {
  name               = "CustomerServiceRoleForManagementS3RdsSnapshot"
  description        = "[Terraform] Role to management snapshots bucket."
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "export.rds.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_export" {
  role       = aws_iam_role.role_export.name
  policy_arn = aws_iam_policy.policy_export.arn
}


resource "aws_iam_policy" "policy_lambda" {
  name        = "AllowExportSnapshotToS3"
  description = "[Terraform] Allow list snapshots and start export task."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole",
                "rds:DescribeDBSnapshots"
            ],
            "Resource": [
                "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:snapshot:*",
                "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:*",
                "arn:aws:iam::*:role/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "rds:StartExportTask"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:GetPublicKey",
                "kms:ListKeyPolicies",
                "kms:GetKeyPolicy",
                "kms:ListGrants",
                "kms:DescribeCustomKeyStores",
                "kms:ListKeys",
                "kms:ListAliases",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role" "role_lambda" {
  name               = "CustomerServiceRoleForLambdaExportSnapshot"
  description        = "[Terraform] Role to enable lambda start task export rds snapshot to S3."
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_lambda" {
  role       = aws_iam_role.role_lambda.name
  policy_arn = aws_iam_policy.policy_lambda.arn
}