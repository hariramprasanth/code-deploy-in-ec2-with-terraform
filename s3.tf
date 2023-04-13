resource "aws_s3_bucket" "web_server_bucket" {
  bucket = "web-server-8797"

  tags = {
    project = "web server"
  }
}

resource "aws_s3_bucket_public_access_block" "web_server_bucket_acl" {
  bucket = aws_s3_bucket.web_server_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "Web_server_s3_bucket_access_policy" {
  name        = "Web-server-s3-bucket-access-policy"
  description = "Allows access to specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.web_server_bucket.arn,
          "${aws_s3_bucket.web_server_bucket.arn}/*"
        ]
      }
    ]
  })
}