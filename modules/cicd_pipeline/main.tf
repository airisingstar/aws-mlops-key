##############################################
# CI/CD Pipeline Module (CodeCommit → CodeBuild → CodePipeline)
# - Builds Docker image for inference (from repo's app_src/inference)
# - Registers a model in SageMaker Model Registry
# - Waits for manual approval
# - Deploys endpoint via CloudFormation using stackset.tpl.yaml
##############################################

variable "name_prefix"          { type = string }
variable "region"               { type = string }
variable "model_registry_name"  { type = string }
variable "ecr_repo_url"         { type = string }
variable "model_bucket_arn"     { type = string }

locals {
  tags = { Project = var.name_prefix, ManagedBy = "aws-mlops-key" }
}

data "aws_caller_identity" "me" {}

# Source repository for your code
resource "aws_codecommit_repository" "repo" {
  repository_name = "${var.name_prefix}-mlops-repo"
  description     = "Source repository for ${var.name_prefix} CI/CD pipeline"
  tags            = local.tags
}

# Artifact bucket for pipeline outputs
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.name_prefix}-mlops-artifacts-${data.aws_caller_identity.me.account_id}"
  force_destroy = true
  tags          = local.tags
}

# IAM roles for CodeBuild & CodePipeline
data "aws_iam_policy_document" "codebuild_assume" {
  statement { effect="Allow"
    principals { type="Service", identifiers=["codebuild.amazonaws.com"] }
    actions=["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "codebuild_role" {
  name               = "${var.name_prefix}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}
resource "aws_iam_role_policy" "codebuild_inline" {
  role = aws_iam_role.codebuild_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect="Allow", Action=["logs:*","s3:*","codecommit:*","ecr:*","cloudformation:*","sagemaker:*","iam:PassRole","sts:AssumeRole"], Resource="*" }
    ]
  })
}

data "aws_iam_policy_document" "pipeline_assume" {
  statement { effect="Allow"
    principals { type="Service", identifiers=["codepipeline.amazonaws.com"] }
    actions=["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.name_prefix}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_assume.json
}
resource "aws_iam_role_policy" "codepipeline_inline" {
  role = aws_iam_role.codepipeline_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect="Allow", Action=["s3:*","codecommit:*","codebuild:*","cloudformation:*","iam:PassRole","sts:AssumeRole"], Resource="*" }
    ]
  })
}

# CodeBuild: Build + push inference image
resource "aws_codebuild_project" "build" {
  name         = "${var.name_prefix}-build"
  service_role = aws_iam_role.codebuild_role.arn
  artifacts { type="S3", location=aws_s3_bucket.artifacts.bucket }
  environment {
    compute_type        = "BUILD_GENERAL1_SMALL"
    image               = "aws/codebuild/standard:7.0"
    type                = "LINUX_CONTAINER"
    privileged_mode     = true
    environment_variable { name="ECR_REPO_URL", value=var.ecr_repo_url }
  }
  source { type="CODECOMMIT", location=aws_codecommit_repository.repo.clone_url_http, buildspec=file("${path.module}/buildspec.build.yml") }
  tags = local.tags
}

# CodeBuild: Register model package
resource "aws_codebuild_project" "register" {
  name         = "${var.name_prefix}-register"
  service_role = aws_iam_role.codebuild_role.arn
  artifacts { type="S3", location=aws_s3_bucket.artifacts.bucket }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
    environment_variable {name="MODEL_REGISTRY", value=var.model_registry_name}
    environment_variable {name="MODEL_BUCKET_ARN", value=var.model_bucket_arn}
    environment_variable {name="ECR_REPO_URL", value=var.ecr_repo_url}
  }
  source { type="CODECOMMIT", location=aws_codecommit_repository.repo.clone_url_http, buildspec=file("${path.module}/buildspec.register.yml") }
  tags = local.tags
}

# Pipeline: Source → Build → Register → Manual Approval → CFN Deploy
resource "aws_codepipeline" "pipeline" {
  name     = "${var.name_prefix}-mlops-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store { location=aws_s3_bucket.artifacts.bucket, type="S3" }

  stage {
    name = "Source"
    action { name="Source", category="Source", owner="AWS", provider="CodeCommit", version="1",
      output_artifacts=["source_output"],
      configuration={ RepositoryName=aws_codecommit_repository.repo.repository_name, BranchName="main" }
    }
  }

  stage {
    name = "Build"
    action { name="BuildImage", category="Build", owner="AWS", provider="CodeBuild", version="1",
      input_artifacts=["source_output"], output_artifacts=["build_output"],
      configuration={ ProjectName=aws_codebuild_project.build.name }
    }
  }

  stage {
    name = "RegisterModel"
    action { name="RegisterModel", category="Build", owner="AWS", provider="CodeBuild", version="1",
      input_artifacts=["build_output"], output_artifacts=["register_output"],
      configuration={ ProjectName=aws_codebuild_project.register.name }
    }
  }

  stage {
    name = "ManualApproval"
    action { name="ApproveForDeploy", category="Approval", owner="AWS", provider="Manual", version="1" }
  }

  stage {
    name = "DeployEndpoint"
    action { name="DeployStack", category="Deploy", owner="AWS", provider="CloudFormation", version="1",
      input_artifacts=["register_output"],
      configuration={
        ActionMode   = "CREATE_UPDATE",
        StackName    = "${var.name_prefix}-sagemaker-endpoint",
        Capabilities = "CAPABILITY_NAMED_IAM",
        # We ship stackset.tpl.yaml in the repo; pipeline will include it via artifacts
        TemplatePath = "register_output::stackset.tpl.yaml",
        # Optional: ParameterOverrides to pass the just-registered ModelPackageArn
        # ParameterOverrides = {"ModelPackageArn":"#{ModelPackageArnFromPrevStage}"}
      }
    }
  }

  tags = local.tags
}

output "pipeline_name" { value = aws_codepipeline.pipeline.name }
