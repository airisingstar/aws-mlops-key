# 🚀 AWS MLOps Pipeline Engine (aws-mlops-key)

> **“From Zero to Production MLOps in One Command.”**  
> A fully automated AWS Machine-Learning Operations (MLOps) pipeline built to power the SaaS engine — the ignition system for automated DevOps + MLOps provisioning.

---

## 🧭 Overview

This repository deploys a **Golden MLOps Pipeline** on AWS using Terraform.  
It creates every service required for a modern ML lifecycle — from code to container to live API endpoint.

The same architecture shown in the official AWS diagram (recreated below) forms the backbone of the **Boss Key Engine**, a fully managed SaaS that allows non-technical founders or small teams to launch full-stack ML pipelines with only a few prompts.

---

## 🏗️ Architecture Diagram

![AWS MLOps Architecture](A_flowchart_diagram_in_digital_vector_graphic_form.png)

---

## ⚙️ What It Deploys

| Layer | AWS Service(s) | Purpose |
|-------|----------------|----------|
| **Source Control** | **CodeCommit** | Stores ML code, training scripts, and inference containers. |
| **Pipeline Orchestrator** | **CodePipeline** | Automates build → register → deploy. |
| **Build Automation** | **CodeBuild (2 projects)** | ① Build & push inference Docker image → ECR ; ② Register model → Model Registry. |
| **Model Versioning** | **SageMaker Model Registry** | Tracks all model versions, approvals, and lineage. |
| **Artifact Store** | **S3 (model & artifact buckets)** | Keeps artifacts, templates, and logs. |
| **Container Repo** | **ECR** | Stores built inference containers. |
| **Deployment Engine** | **CloudFormation StackSet** | Creates/updates SageMaker Endpoint consistently across accounts/regions. |
| **Serving Layer** | **SageMaker Endpoint** | Hosts the latest approved model as a REST API. |
| **Monitoring** | **CloudWatch + S3 (Monitoring Bucket)** | Collects metrics + logs for drift, latency, and failures. |
| **Networking** | **VPC + Subnets (Private)** | Secure environment for builds and endpoints. |

---

## 🔄 Full Lifecycle Flow

1. **Push code to CodeCommit**  
   → triggers the MLOps pipeline.

2. **CodePipeline starts automatically**  
   → orchestrates the full process.

3. **CodeBuild (Build)**  
   → builds inference Docker image → pushes to ECR.

4. **CodeBuild (Register)**  
   → registers the new model in the Model Registry.

5. **Manual Approval Stage**  
   → approve in CodePipeline console before deploy.

6. **CloudFormation StackSet**  
   → deploys SageMaker Model → Endpoint → live API.

7. **CloudWatch + S3**  
   → record metrics, drift, and usage logs.

---

## 🧩 Repository Structure

aws-mlops-key/
├── main.tf, providers.tf, variables.tf, outputs.tf
├── modules/
│ ├── environment/ # Brain: wires all modules together
│ ├── shared_vpc/ # VPC + subnets
│ ├── artifact_foundation/ # S3, ECR, Model Registry
│ ├── cicd_pipeline/ # CodeCommit, CodeBuild, CodePipeline
│ ├── endpoint_stackset/ # CloudFormation StackSet → SageMaker
│ └── ops_monitoring/ # Monitoring bucket & dashboard stub
├── app_src/
│ └── inference/ # Simple FastAPI inference example
├── envs/ # tfvars templates per client/env
├── scripts/ # helper scripts (deploy/destroy/onboard)
└── .github/workflows/ # optional GitHub Actions automation

yaml
Copy code

---

## 🧠 Default Behavior

Running the demo (`envs/client-demo.tfvars`) will automatically create:

| Resource | Example Name |
|-----------|---------------|
| VPC | `demo-vpc` |
| S3 (Model Artifacts) | `demo-model-artifacts` |
| ECR Repo | `demo/inference` |
| Model Registry | `demo-registry` |
| CodeCommit Repo | `demo-mlops-repo` |
| CodeBuild Projects | `demo-build`, `demo-register` |
| CodePipeline | `demo-mlops-pipeline` |
| Endpoint StackSet | `demo-sagemaker-endpoint` |
| Endpoint Deployed Name | `demo-sagemaker-endpoint-endpoint` |

Everything is prefixed with your `name_prefix` variable.

---

## 🚀 Quick Start

### 1. Create AWS credentials
Make sure you have:
```bash
aws configure
# Enter Access Key / Secret / Region
2. Deploy demo environment
bash
Copy code
git clone https://github.com/<you>/aws-mlops-key.git
cd aws-mlops-key
terraform init
terraform apply -var-file=envs/client-demo.tfvars
3. Push your code to start the pipeline
bash
Copy code
# Get the repo URL from AWS CodeCommit console
git remote add codecommit <your-repo-url>
git add app_src
git commit -m "seed demo model"
git push codecommit main
Once pushed, the pipeline runs automatically and ends with a live SageMaker Endpoint.

💡 What You Can Do After Deployment
Capability	Description
Train + Deploy Automatically	Any new model or container push redeploys a new endpoint.
Model Versioning	Every model version stored + approved via the Model Registry.
Live Inference API	Call your deployed endpoint directly via HTTPS.
Continuous Delivery	CodePipeline keeps your model infra evergreen.
Multi-Client Scaling	Each client.tfvars = fully isolated environment.
Boss Key Integration	Boss Key UI will act as SaaS control panel invoking this backend.

💰 Typical Costs
Item	Est. Monthly (24/7 running)
SageMaker Endpoint (ml.m5.large)	$84
CodePipeline + CodeBuild + Storage	~$5
CloudWatch Monitoring	~$3
Total ≈ $89 / month	✅

🧠 Tip: Switch to ml.t3.medium (~$40/mo) or delete the endpoint when idle to minimize cost.

🧹 Cleaning Up (Deleting Everything)
To destroy all resources created by Terraform:

bash
Copy code
./scripts/destroy.sh
# or manually:
terraform destroy -auto-approve -var-file=envs/client-demo.tfvars
Terraform tracks all resources in its state file and removes them cleanly.
If S3 buckets block deletion, empty them manually and rerun.

🌩️ Roadmap (Boss Key UI Integration)
 Terraform MLOps Engine (this repo)

 Boss Key API — FastAPI service to run Terraform via REST

 Boss Key UI — Next.js + Tailwind wizard for non-technical onboarding

 Client Dashboard → show pipeline + endpoint status

 Cost estimation + auto teardown scheduler

🏁 Credits & License
Built by MyAiToolset LLC
© 2025 MyAiToolset LLC · All Rights Reserved


# AWS MLOps Key — Boss Key Engine 🚀

**What this is:** a fully working, annotated *Golden MLOps* pipeline for AWS.
It provisions a VPC, artifact stores (S3/ECR/Model Registry), a CI/CD pipeline
(CodeCommit → CodeBuild → CodePipeline), and deploys a SageMaker Endpoint via
CloudFormation.

**Who it's for:** non‑infra founders and busy teams. Answer a few prompts (or
set a `.tfvars`) and press launch — Boss Key (future UI) will call this repo
under the hood.

---

## Quick Start

```bash
cp envs/client-template.tfvars envs/client-demo.tfvars
# edit values if you want, then:
terraform init
terraform apply -var-file=envs/client-demo.tfvars
```

After apply, a CodeCommit repo named `<name_prefix>-mlops-repo` is created.
Push the contents of `app_src/` there to trigger the pipeline.

---

## What gets created

- **VPC** with two private subnets
- **S3** bucket for model artifacts
- **ECR** repository for inference images
- **SageMaker Model Registry** (Model Package Group)
- **CodeCommit** repository
- **CodeBuild** projects (build image & register model)
- **CodePipeline** (Source → Build → Register → Approval → Deploy)
- **CloudFormation StackSet** that deploys a **SageMaker Endpoint**
- **(Optional) Monitoring** bucket & dashboard (starter)

---

## Repo Map

- `modules/environment` – brains that wires everything together
- `modules/shared_vpc` – minimal VPC + subnets
- `modules/artifact_foundation` – S3/ECR/Model Registry
- `modules/cicd_pipeline` – CodeCommit/Build/Pipeline (+ buildspecs)
- `modules/endpoint_stackset` – StackSet to create SageMaker Endpoint
- `modules/ops_monitoring` – starter monitoring
- `app_src/` – tiny FastAPI app & placeholder model for demos
- `envs/*.tfvars` – per‑client / per‑env presets
- `scripts/*.sh` – one‑liners to onboard clients or deploy/destroy
- `.github/workflows/deploy.yml` – optional GitHub Actions workflow

## 📦 Overview

Running `terraform apply` will stand up a **complete MLOps environment** including:
- Secure **VPC** with subnets
- CI/CD pipelines (CodeCommit → CodeBuild → CodePipeline)
- Model artifact storage (S3 + ECR + SageMaker Registry)
- Automated model packaging and SageMaker Endpoint deployment via CloudFormation StackSets
- Monitoring and logging buckets for audit trail

---

## 🧰 Modules Created

### 1️⃣ Shared VPC (`modules/shared_vpc`)
| Resource | Description |
|-----------|--------------|
| `aws_vpc.main` | Main network (CIDR: `10.21.0.0/16`) |
| `aws_subnet.private_a` | Private subnet A (`us-east-1a`, `10.21.16.0/20`) |
| `aws_subnet.private_b` | Private subnet B (`us-east-1b`, `10.21.32.0/20`) |

**Outputs**
- `vpc_id`
- `subnet_ids`

---

### 2️⃣ Artifact Foundation (`modules/artifact_foundation`)
| Resource | Description |
|-----------|--------------|
| `aws_s3_bucket.model_artifacts` | Stores model tarballs, training outputs |
| `aws_sagemaker_model_package_group.registry` | Central SageMaker Model Registry |
| `aws_ecr_repository.inference` | Container image repo for inference builds |

---

### 3️⃣ CI/CD Pipeline (`modules/cicd_pipeline`)
| Resource | Description |
|-----------|--------------|
| `aws_codecommit_repository.repo` | Source repo for inference code and pipeline specs |
| `aws_s3_bucket.artifacts` | Pipeline artifact store |
| `aws_iam_role.codebuild_role` | Execution role for CodeBuild |
| `aws_iam_role.codepipeline_role` | Role for CodePipeline orchestration |
| `aws_codebuild_project.build` | Builds and pushes inference Docker image to ECR |
| `aws_codebuild_project.register` | Registers SageMaker ModelPackage & uploads stackset.tpl.yaml |
| `aws_codepipeline.pipeline` | Orchestrates CI/CD: Source → Build → Register → Manual Approval → DeployEndpoint |

**Pipeline Stages**
1. **Source** → from CodeCommit branch `main`  
2. **BuildImage** → Docker build + push to ECR  
3. **RegisterModel** → Creates/updates SageMaker ModelPackage  
4. **ManualApproval** → requires manual “Approve for Deploy”  
5. **DeployStack** → Creates endpoint via CloudFormation

**Outputs**
- `pipeline_name` → `demo-mlops-pipeline`

---

### 4️⃣ Endpoint StackSet (`modules/endpoint_stackset`)
| Resource | Description |
|-----------|--------------|
| `aws_cloudformation_stack_set.endpoint` | Defines SageMaker endpoint deployment template |
| `aws_cloudformation_stack_set_instance.this` | Deploys the endpoint instance in `us-east-1` |

**Template Parameters**
- `ModelPackageArn`: passed from the registered model stage

**Outputs**
- `endpoint_name` → `demo-sagemaker-endpoint-endpoint`

---

### 5️⃣ Operations & Monitoring (`modules/ops_monitoring`)
| Resource | Description |
|-----------|--------------|
| `aws_s3_bucket.monitoring` | Stores logs, metrics, and event data |

---

## 🗂️ Total Resources Created

| Category | Resource Count |
|-----------|----------------|
| Networking (VPC/Subnets) | 3 |
| Artifact Management (S3, ECR, SageMaker Registry) | 3 |
| CI/CD (CodeCommit, CodeBuild, CodePipeline, IAM Roles) | 8 |
| Endpoint Deployment (CloudFormation StackSet + Instance) | 2 |
| Monitoring | 1 |
| **Total** | **18 resources** |

---

## 🧩 Outputs Summary

| Output | Example Value |
|---------|----------------|
| `pipeline_name` | demo-mlops-pipeline |
| `endpoint_name` | demo-sagemaker-endpoint-endpoint |
| `vpc_id` | vpc-xxxxxx |
| `subnet_ids` | [subnet-aaa, subnet-bbb] |

---

## ⚙️ How to Deploy

```bash
terraform init
terraform plan -var-file="envs/client-demo.tfvars"
terraform apply -var-file="envs/client-demo.tfvars"
Confirm with yes when prompted.

🧭 AWS Console Navigation Guide
Service	Console Path
CodeCommit	Repositories → demo-mlops-repo
CodePipeline	Pipelines → demo-mlops-pipeline
CodeBuild	Projects → demo-build, demo-register
ECR	Repositories → demo/inference
SageMaker	Model Registry → demo-registry
CloudFormation	StackSets → demo-sagemaker-endpoint
S3	Buckets → demo-model-artifacts, demo-mlops-artifacts-*, demo-monitoring

🧹 Cleanup
To destroy all infrastructure:

bash
Copy code
terraform destroy -var-file="envs/client-demo.tfvars"

---
```

Author: David Santana Rivera
Updated: 10/31/2025
