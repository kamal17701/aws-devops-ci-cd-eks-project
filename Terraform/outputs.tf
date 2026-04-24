output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  description = "URL of the ECR repository — use this in your CI/CD pipeline"
  value       = module.ecr.repository_url
}

output "kubeconfig_command" {
  description = "Run this command to configure kubectl after apply"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
