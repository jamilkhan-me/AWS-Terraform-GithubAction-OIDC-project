resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "site" {
  bucket = "${var.project_name}-site-${random_id.suffix.hex}"

  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

#Creating S3 bucket

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}
