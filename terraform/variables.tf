
variable "aws_region" {
  description = "AWS region to launch servers."
}

variable "bucket_name" {
  description = "Name of bucket on s3 to backup snapshots in parquet format."
}

variable "cloud_watch_cron" {
  description = "Cron to call aws lambda. Ex:'cron(0 1 * * * *)'"

}

