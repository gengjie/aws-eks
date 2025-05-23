output "cluster_endpoint" {
  description = "EKS集群API端点"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS集群名称"
  value       = var.cluster_name
}

output "kubeconfig" {
  description = "生成kubeconfig配置"
  value       = module.eks.kubeconfig
  sensitive   = true
}