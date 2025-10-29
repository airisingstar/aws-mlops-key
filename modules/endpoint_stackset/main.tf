# CloudFormation StackSet wrapper (kept for future multi-account expansion).
locals { tags = { Project = var.name_prefix, ManagedBy = "aws-mlops-key" } }

resource "aws_cloudformation_stack_set" "endpoint" {
  name             = "${var.name_prefix}-sagemaker-endpoint"
  permission_model = "SELF_MANAGED"
  parameters = { ModelPackageArn = var.model_package_arn }
  template_body = file("${path.module}/stackset.tpl.yaml")
  capabilities  = ["CAPABILITY_NAMED_IAM"]
  tags          = local.tags
}

resource "aws_cloudformation_stack_set_instance" "this" {
  stack_set_name = aws_cloudformation_stack_set.endpoint.name
  region         = var.region
}

output "stackset_name" { value = aws_cloudformation_stack_set.endpoint.name }
