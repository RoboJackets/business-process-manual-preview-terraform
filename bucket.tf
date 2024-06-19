resource "aws_s3_bucket" "statefiles" {
  bucket = "gatech-me-robojackets-bpm-preview-statefiles"

  object_lock_enabled = false
}

resource "aws_s3_bucket_public_access_block" "statefiles" {
  bucket = aws_s3_bucket.statefiles.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
