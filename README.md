<div align="center">

# 🚀 End-to-End DevOps Pipeline on AWS
### Java Microservice · GitHub Actions CI/CD · Docker · EKS · Terraform · Ansible · Prometheus

[![CI/CD Pipeline](https://github.com/kamal17701/aws-devops-ci-cd-eks-project/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/kamal17701/aws-devops-ci-cd-eks-project/actions/workflows/ci-cd.yml)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](./Terraform)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&logoColor=white)](./Dockerfile)
[![Kubernetes](https://img.shields.io/badge/Orchestration-EKS-FF9900?logo=amazonaws&logoColor=white)](./kubernetes)
[![Java](https://img.shields.io/badge/App-Java%2017%20Maven-007396?logo=openjdk&logoColor=white)](./pom.xml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Tech Stack](#-tech-stack)
- [What I Built](#-what-i-actually-built)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Monitoring](#-monitoring--observability)
- [Security](#-security)
- [Lessons Learned](#-lessons-learned)
- [Roadmap](#-roadmap)

---

## 🎯 Overview

A **production-style DevOps project** demonstrating a complete, automated delivery pipeline for a containerised Java microservice on AWS.

Every layer is covered: application build → containerisation → cloud infrastructure provisioning → Kubernetes deployment → monitoring and alerting. The focus is on **automation, reliability, and the engineering discipline** that separates a working pipeline from a production-ready one.

**The pipeline in one line:**
```
git push → GitHub Actions → Maven Build + Tests → Docker → ECR → Terraform → EKS → Prometheus/Grafana
```

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                        DEVELOPER WORKFLOW                             │
│                                                                      │
│   Developer  ──►  git push  ──►  GitHub (main branch)               │
│                                       │                              │
│              ┌────────────────────────▼──────────────────────────┐  │
│              │              GitHub Actions Pipeline               │  │
│              │                                                    │  │
│              │  ┌─────────────┐   ┌──────────────┐   ┌────────┐  │  │
│              │  │  JOB 1      │──►│   JOB 2      │──►│ JOB 3  │  │  │
│              │  │  Build &    │   │  Docker      │   │ Deploy │  │  │
│              │  │  Test       │   │  Build+Push  │   │ to EKS │  │  │
│              │  │  (Maven)    │   │  (ECR)       │   │        │  │  │
│              │  └─────────────┘   └──────────────┘   └────────┘  │  │
│              └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
                                      │
              ┌───────────────────────▼──────────────────────────┐
              │                  AWS Cloud                        │
              │                                                   │
              │   ┌──────────────────────────────────────────┐   │
              │   │           VPC  (10.0.0.0/16)             │   │
              │   │                                          │   │
              │   │  ┌─────────────┐    ┌─────────────────┐  │   │
              │   │  │Public Subnet│    │ Private Subnet  │  │   │
              │   │  │             │    │                 │  │   │
              │   │  │  ALB ◄──────┼────┼── EKS Nodes    │  │   │
              │   │  │  (Ingress)  │    │  (t3.medium×2) │  │   │
              │   │  └─────────────┘    └────────┬────────┘  │   │
              │   │        NAT Gateway            │           │   │
              │   └───────────────────────────────┼───────────┘   │
              │                                   │               │
              │   ECR ◄── Docker Images      EKS Cluster          │
              │   S3  ◄── Terraform State    ┌───┴────────────┐   │
              │   DynamoDB ◄── State Lock    │  kamalapp Pods │   │
              │   CloudWatch ◄── Logs/Alerts │  (HPA: 2–10)   │   │
              │                              └────────────────┘   │
              └───────────────────────────────────────────────────┘
                                      │
              ┌───────────────────────▼──────────────────────────┐
              │              Monitoring Stack                     │
              │   Prometheus ──► Grafana Dashboards               │
              │   CloudWatch Logs ──► SNS Email Alerts            │
              └───────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
aws-devops-ci-cd-eks-project/
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # 3-stage GitHub Actions pipeline
│
├── Terraform/
│   ├── main.tf                    # Root module — wires VPC + EKS + ECR
│   ├── variables.tf               # All input variables with validation
│   ├── outputs.tf                 # Cluster endpoint, ECR URL, kubeconfig cmd
│   ├── backend.tf                 # S3 remote state + DynamoDB locking
│   └── modules/
│       ├── vpc/main.tf            # VPC, subnets, IGW, NAT, route tables
│       ├── eks/main.tf            # EKS cluster, node group, IAM roles
│       └── ecr/main.tf            # ECR repo, lifecycle policy, encryption
│
├── kubernetes/
│   ├── deployment.yaml            # Rolling deploy, readiness/liveness probes
│   ├── service.yaml               # ClusterIP service
│   ├── ingress.yaml               # AWS ALB Ingress Controller
│   └── hpa.yaml                   # HorizontalPodAutoscaler (CPU + memory)
│
├── ansible/
│   ├── inventory/hosts.ini        # EC2 host inventory
│   ├── playbooks/setup.yml        # Bootstrap: Docker, kubectl, Java, AWS CLI
│   └── roles/app/tasks/main.yml   # App-level config tasks
│
├── src/
│   └── main/java/com/kamal/devops/
│       ├── KamalAppApplication.java        # Spring Boot entry point
│       ├── controller/HealthController.java # GET /health, GET /info
│       └── config/ActuatorConfig.java       # Prometheus metrics config
│
├── Dockerfile                     # Multi-stage build, non-root user
├── Jenkinsfile                    # Jenkins declarative pipeline (alternative to GHA)
├── pom.xml                        # Maven — Spring Boot + Actuator + Prometheus
└── README.md
```

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Cloud** | AWS EKS, ECR, EC2, VPC, IAM, ALB, CloudWatch, SNS | Hosting + networking + security |
| **CI/CD** | GitHub Actions (primary) + Jenkins (alternative) | Automated build, test, deploy |
| **Containers** | Docker (multi-stage, non-root) | Reproducible, secure builds |
| **Orchestration** | Kubernetes on EKS | Scalable, self-healing deployments |
| **IaC** | Terraform (modular, remote state) | Reproducible infra provisioning |
| **Config Mgmt** | Ansible | EC2 bootstrap, environment config |
| **Monitoring** | Prometheus + Grafana + CloudWatch | Metrics, dashboards, alerts |
| **Application** | Java 17 + Spring Boot + Maven | REST microservice deployment target |
| **Security** | OIDC IAM, non-root containers, ECR scanning | No hardcoded secrets anywhere |

---

## ✅ What I Actually Built

### What Works
- **Full CI pipeline** — on every `git push` to `main`: Maven builds the JAR, runs unit tests, builds a Docker image tagged with the git SHA, and pushes it to ECR
- **Terraform provisions** from scratch: a custom VPC with public/private subnets, NAT gateway, EKS cluster with a managed node group (t3.medium × 2), and ECR repository — all using modular HCL with S3 remote state and DynamoDB locking
- **Kubernetes manifests** deploy with zero-downtime rolling updates, HPA autoscaling (2–10 pods), ALB Ingress, and proper `readinessProbe` / `livenessProbe` on `/health`
- **Ansible playbook** bootstraps fresh EC2 instances: installs Docker, kubectl, Java 17, Maven, AWS CLI — idempotent with tagged tasks
- **Prometheus + Grafana** deployed into the cluster via Helm, scraping the `/actuator/prometheus` endpoint on app pods
- **CloudWatch** captures all container logs via the CloudWatch Agent DaemonSet, with SNS alerts on 5xx error spikes

### What I'd Do Differently in Production
- **Secrets management** — currently using GitHub Secrets; would migrate to AWS Secrets Manager with automatic rotation
- **No TLS/HTTPS** on the ingress — would add ACM certificate + Route53 alias record
- **No staging environment** — a real setup would have `dev → staging → prod` with manual approval gates between stages
- **No drift detection** — would add Atlantis or `terraform plan` running on every PR to catch config drift
- **The app is intentionally minimal** — the real complexity here is the infrastructure and automation layer, not the application

---

## 📦 Prerequisites

- AWS CLI configured: `aws configure`
- Terraform ≥ 1.5: `terraform -version`
- kubectl installed: `kubectl version --client`
- Docker installed: `docker --version`
- Java 17 + Maven: `java -version && mvn -version`

---

## ⚡ Quick Start

### 1. Clone the repo
```bash
git clone https://github.com/kamal17701/aws-devops-ci-cd-eks-project.git
cd aws-devops-ci-cd-eks-project
```

### 2. Provision AWS infrastructure with Terraform
```bash
cd Terraform/

# Initialise — downloads providers, configures S3 backend
terraform init

# Preview what will be created
terraform plan -out=tfplan

# Create VPC + EKS + ECR (~10–12 minutes)
terraform apply tfplan
```

### 3. Configure kubectl to talk to your new cluster
```bash
# Terraform outputs this command for you:
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name kamal-eks-cluster
```

### 4. Bootstrap EC2 Jenkins agent with Ansible (optional)
```bash
cd ansible/
# Edit inventory/hosts.ini with your EC2 IP
ansible-playbook -i inventory/hosts.ini playbooks/setup.yml
```

### 5. Build and deploy manually (CI does this automatically)
```bash
# Build the JAR
mvn clean package -DskipTests

# Build and push Docker image
ECR_URL=$(cd Terraform && terraform output -raw ecr_repository_url)
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS --password-stdin $ECR_URL

docker build -t $ECR_URL:latest .
docker push $ECR_URL:latest

# Deploy to EKS
sed -i "s|IMAGE_PLACEHOLDER|$ECR_URL:latest|g" kubernetes/deployment.yaml
kubectl apply -f kubernetes/
kubectl rollout status deployment/kamalapp
```

### 6. Check your deployment
```bash
kubectl get pods -n default
kubectl get ingress -n default
# Access the app at the ALB hostname shown in the ingress output
```

### 7. Tear down when done (saves ~$6–8/day in AWS costs)
```bash
kubectl delete -f kubernetes/
cd Terraform/ && terraform destroy
```

---

## 🔁 CI/CD Pipeline

The GitHub Actions pipeline (`.github/workflows/ci-cd.yml`) runs three sequential jobs:

```
┌─────────────────────────────────────────────────────────────┐
│  Trigger: push to main / pull_request                        │
└──────────────────────────────┬──────────────────────────────┘
                               │
               ┌───────────────▼───────────────┐
               │  JOB 1: Build & Test (Maven)   │
               │  • actions/checkout            │
               │  • Setup Java 17               │
               │  • mvn clean package           │
               │  • Upload JAR artifact         │
               └───────────────┬───────────────┘
                               │ (on main branch only)
               ┌───────────────▼───────────────┐
               │  JOB 2: Docker Build + ECR     │
               │  • OIDC → assume AWS IAM role  │
               │  • docker build (multi-stage)  │
               │  • Tag with git SHA            │
               │  • docker push → ECR           │
               └───────────────┬───────────────┘
                               │
               ┌───────────────▼───────────────┐
               │  JOB 3: Deploy to EKS          │
               │  • aws eks update-kubeconfig   │
               │  • sed image tag into YAML     │
               │  • kubectl apply -f kubernetes/│
               │  • kubectl rollout status      │
               │  • curl /health check          │
               └───────────────────────────────┘
```

**Required GitHub Secrets:**
| Secret | Description |
|---|---|
| `AWS_IAM_ROLE_ARN` | ARN of the IAM role GitHub Actions assumes via OIDC |

> No AWS access keys are stored in GitHub. Authentication uses OIDC federation — the industry standard.

---

## 📊 Monitoring & Observability

| Tool | What it monitors | How to access |
|---|---|---|
| **Prometheus** | Pod CPU/memory, HTTP request rate, JVM metrics | `kubectl port-forward svc/prometheus 9090:9090` |
| **Grafana** | Visual dashboards for all Prometheus metrics | `kubectl port-forward svc/grafana 3000:3000` (admin/admin) |
| **CloudWatch** | Container logs, cluster metrics, error rates | AWS Console → CloudWatch → Log Groups |
| **SNS** | Email alert when HTTP 5xx rate > 5% for 5 mins | Configured in CloudWatch Alarm |

---

## 🔐 Security

- **OIDC authentication** — GitHub Actions assumes an IAM role via OIDC; no long-lived access keys anywhere
- **Least-privilege IAM** — EKS node role has only ECR pull + CloudWatch write permissions
- **Non-root container** — Dockerfile creates a dedicated `appuser`; `runAsNonRoot: true` in the pod spec
- **Read-only filesystem** — `readOnlyRootFilesystem: true` in the security context
- **ECR image scanning** — enabled on push; CRITICAL CVEs would block deployment
- **All capabilities dropped** — `capabilities.drop: ["ALL"]` in the container security context

---

## 📝 Lessons Learned

**1. EKS node IAM roles are silent failures**
Missing the `AmazonEC2ContainerRegistryReadOnly` policy causes `ImagePullBackOff` with no obvious error. Always verify with `aws sts get-caller-identity` from the node.

**2. readinessProbe is not optional**
Without it, Kubernetes routes traffic to pods that are still starting up, causing 502 errors during rolling deploys. Learned this after the first failed zero-downtime deployment attempt.

**3. Terraform state locking matters**
Running two `terraform apply` commands concurrently without DynamoDB locking corrupted state. Adding the lock table was a 5-minute fix that prevented hours of recovery.

**4. NAT Gateway billing**
AWS charges for NAT Gateway per GB transferred and per hour of existence. Always `terraform destroy` after testing. Cost me ~$12 on a forgotten overnight run.

**5. Docker layer caching**
Copying `pom.xml` first and running `mvn dependency:go-offline` before copying source cuts Docker build time from ~3 minutes to ~30 seconds on unchanged dependencies.

---

## 🗺️ Roadmap

- [ ] Add ArgoCD for GitOps-based continuous delivery (replace `kubectl apply` in pipeline)
- [ ] Add Trivy image vulnerability scanning as a pipeline gate
- [ ] Multi-environment setup (dev/staging/prod) using Terraform workspaces
- [ ] Migrate secrets to AWS Secrets Manager
- [ ] Add HTTPS via ACM certificate + Route53
- [ ] Add KEDA for event-driven pod autoscaling

---

## 👤 Author

**Kamal** — DevOps Engineer  
[GitHub](https://github.com/kamal17701) · [LinkedIn](https://www.linkedin.com/in/YOUR-LINKEDIN-HERE)

> Built to learn by doing. Every component was provisioned, broken, debugged, and fixed manually before being automate.

