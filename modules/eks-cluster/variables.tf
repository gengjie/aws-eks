variable "cluster_name" {
  description = "EKS集群名称"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes版本"
  type        = string
  default     = "1.27"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "私有子网列表"
  type        = list(string)
}

variable "hosted_zone_id" {
  description = "Route53托管区域ID"
  type        = string
}

variable "cluster_domain" {
  description = "集群访问域名"
  type        = string
}

variable "elasticsearch_endpoint" {
  description = "Elasticsearch服务端点"
  type        = string
}

variable "elasticsearch_auth" {
  description = "Elasticsearch认证信息"
  type        = string
  sensitive   = true
}

variable "prometheus_enabled" {
  description = "是否启用Prometheus监控"
  type        = bool
  default     = true
}

variable "remote_write_url" {
  description = "远程写入端点URL (VictoriaMetrics/Mimir)"
  type        = string
  default     = ""
}

variable "remote_write_username" {
  description = "远程写入认证用户名"
  type        = string
  default     = ""
}

variable "remote_write_password" {
  description = "远程写入认证密码"
  type        = string
  sensitive   = true
  default     = ""
}