resource "aws_cloudwatch_event_rule" "tue_thu_sat" {
  name                = "CronRdsSnapshotExporterS3"
  description         = "[Terraform] Cron to start lambda that export RDS snapshot to S3."
  schedule_expression = var.cloud_watch_cron
}

resource "aws_cloudwatch_event_target" "start_lambda_export_snap" {
  rule  = aws_cloudwatch_event_rule.tue_thu_sat.name
  arn   = aws_lambda_function.lamba_export.arn
  input = var.cloud_watch_event_input
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_export_snapshot" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lamba_export.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.tue_thu_sat.arn
}