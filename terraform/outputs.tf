

output "site_bucket_name" {
  description = "S3 bucket name the workflow deploys to"
  value       = aws_s3_bucket.site.bucket
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}
