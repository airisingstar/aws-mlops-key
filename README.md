# 🚀 Boss Key — AWS MLOps Engine (aws-mlops-key)

> **“From Zero to Production MLOps in One Command.”**  
> A fully automated AWS Machine-Learning Operations (MLOps) pipeline built to power the **Boss Key** SaaS engine — the ignition system for automated DevOps + MLOps provisioning.

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

---

© 2025 MyAiToolset LLC · Boss Key engine
