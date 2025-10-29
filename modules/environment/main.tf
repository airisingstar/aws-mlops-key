# The "brain" module that composes all building blocks into one stack.
module "vpc" {
  source      = "../shared_vpc"
  name_prefix = var.name_prefix
  region      = var.region
  vpc_cidr    = var.vpc_cidr
}

module "artifact" {
  source      = "../artifact_foundation"
  name_prefix = var.name_prefix
}

module "cicd" {
  source              = "../cicd_pipeline"
  name_prefix         = var.name_prefix
  region              = var.region
  model_registry_name = module.artifact.model_registry_name
  ecr_repo_url        = module.artifact.ecr_repo_url
  model_bucket_arn    = module.artifact.model_bucket_arn
}

module "endpoint" {
  source             = "../endpoint_stackset"
  name_prefix        = var.name_prefix
  region             = var.region
  # model_package_arn intentionally left blank here;
  # the CodePipeline's Deploy stage uses its own template with parameter.
}

module "ops" {
  source      = "../ops_monitoring"
  name_prefix = var.name_prefix
}

# Surface some useful values to the root module
output "pipeline_name" { value = module.cicd.pipeline_name }
output "endpoint_name" { value = "${var.name_prefix}-sagemaker-endpoint-endpoint" }
output "vpc_id"        { value = module.vpc.vpc_id }
output "subnet_ids"    { value = module.vpc.subnet_ids }
