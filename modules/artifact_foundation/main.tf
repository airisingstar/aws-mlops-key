# Buckets + Registries that hold model artifacts & images
resource "aws_s3_bucket" "model_artifacts" {
  bucket        = "${var.name_prefix}-model-artifacts"
  force_destroy = true
  tags = { Project = var.name_prefix, ManagedBy = "aws-mlops-key" }
}

resource "aws_ecr_repository" "inference" {
  name = "${var.name_prefix}/inference"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = { Project = var.name_prefix, ManagedBy = "aws-mlops-key" }
}

resource "aws_sagemaker_model_package_group" "registry" {
  model_package_group_name        = "${var.name_prefix}-registry"
  model_package_group_description = "Central model registry for ${var.name_prefix}"
  tags = { Project = var.name_prefix, ManagedBy = "aws-mlops-key" }
}

output "model_bucket"        { value = aws_s3_bucket.model_artifacts.bucket }
output "model_bucket_arn"    { value = aws_s3_bucket.model_artifacts.arn }
output "ecr_repo_url"        { value = aws_ecr_repository.inference.repository_url }
output "model_registry_name" { value = aws_sagemaker_model_package_group.registry.model_package_group_name }
