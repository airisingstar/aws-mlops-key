# Minimal monitoring artifacts (starter)
resource "aws_s3_bucket" "monitoring" {
  bucket        = "${var.name_prefix}-monitoring"
  force_destroy = true
  tags = { Project = var.name_prefix, ManagedBy = "aws-mlops-key" }
}
output "monitoring_bucket" { value = aws_s3_bucket.monitoring.bucket }
