output "key_id" {
  value = aws_kms_key.encript_key.key_id
}

output "role_arn" {
  value = aws_iam_role.role_export.arn
}