provider "aws" {
  region = "var.aws_region"
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "var.S3AssestsBucketName"
  acl    = "private"

  website = {
    index_document = "index.html"
  }

  metric_configuration = {
    Name = "EntireBucket"
  }
 # control_object_ownership = true
 # object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  tags = {
    Name = "AssetsBucket"
    Project = "MM"
  }
}




# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "assets_cdn_oai" {
  comment = "Origin Access Identity for AssetsCDN"
}

# S3 bucket policy for assets bucket
resource "aws_s3_bucket_policy" "assets_bucket_policy" {
  bucket = aws_s3_bucket.assets_bucket.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "PolicyForCloudFrontPrivateContent",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.assets_bucket.arn}/*",
        Condition = {
          StringLike = {
            aws_s3_bucket_origin_access_identity = aws_cloudfront_origin_access_identity.assets_cdn_oai.cloudfront_origin_access_identity_path,
          }
        },
      },
    ],
  })
}
