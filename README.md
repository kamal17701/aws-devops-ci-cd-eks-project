End-to-End DevOps Project on AWS (Microservices + CI/CD + EKS)
Project Overview
This project demonstrates a production-style DevOps pipeline for deploying a containerized Java (Maven) microservice on AWS. It covers the complete lifecycle from code commit → CI/CD → containerization → infrastructure provisioning → Kubernetes deployment → monitoring & logging.
The goal is to showcase automation, scalability, and reliability using modern DevOps tools and best practices.

Architecture
Developer → GitHub → CI/CD (Jenkins / GitHub Actions)
        → Docker Build → AWS ECR
        → Terraform (Provision AWS Infra)
        → EKS Cluster (Kubernetes Deployment)
        → Monitoring (Prometheus + Grafana + CloudWatch)

Cloud
-AWS (EKS, ECR, EC2, IAM, VPC, CloudWatch)

CI/CD
-Jenkins
-GitHub Actions

Containerization & Orchestration
-Docker
-Kubernetes (EKS)

Infrastructure as Code
-Terraform

Configuration Management
-Ansible

Monitoring & Logging
-Prometheus
-Grafana
-AWS CloudWatch

Application
-Java (Maven-based microservice)


CI/CD Workflow
-Developer pushes code to GitHub
-CI/CD pipeline (Jenkins / GitHub Actions) is triggered
-Application is built using Maven
-Docker image is created
-Image is pushed to AWS ECR
-Kubernetes manifests are updated
-Application is deployed to EKS cluster
-Monitoring & alerts are triggered via Prometheus/Grafana

Monitoring & Observability
-Prometheus collects application & cluster metrics
-Grafana provides dashboards for visualization
-CloudWatch handles logs and alerts
-Improved system reliability and faster issue detection

Achievements
-Automated end-to-end deployment pipeline
-Reduced manual deployment effort significantly
-Improved scalability and reliability using Kubernetes
-Enabled real-time monitoring and alerting
