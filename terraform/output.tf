output "code_repository" {
  description = "Code repository for the web application."
  value = aws_codecommit_repository.assets_code_repository.repository_name
}

output "web_application" {
  description = "The URL for the web application"
  value = "https://${aws_cloudfront_distribution.assets_cdn.domain_name}"
}

