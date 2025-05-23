# AWS EKS 项目文档

## 概述
本项目主要围绕 Amazon Elastic Kubernetes Service (EKS) 展开，EKS 作为亚马逊提供的托管式 Kubernetes 服务，能够帮助我们在 AWS 上轻松运行 Kubernetes 集群，无需自行搭建和管理 Kubernetes 控制平面。此项目旨在通过一系列工具和脚本，简化 EKS 集群的创建、管理和应用部署流程，提高开发和运维效率。

## 项目背景
在当今的云原生应用开发与部署场景中，Kubernetes 已成为容器编排的事实标准。然而，自行搭建和维护 Kubernetes 集群需要投入大量的时间和精力，包括控制平面的高可用配置、节点的自动扩缩容管理等。AWS EKS 提供了一个便捷的解决方案，将这些复杂的管理工作交给 AWS 处理，让开发者能够专注于业务应用的开发。本项目基于 EKS 构建，旨在提供一套完整的 EKS 集群管理和应用部署方案。

## 监控数据持久化

### VictoriaMetrics/Mimir 配置
在`variables.tf`中配置以下参数实现Prometheus远程写入：

```hcl
# 启用Prometheus监控（默认已启用）
prometheus_enabled = true

# 远程写入端点（根据使用的存储系统选择）
remote_write_url = "http://victoriametrics:8428/api/v1/write"  # 单节点VictoriaMetrics
remote_write_url = "http://mimir-distributor:9009/api/v1/push" # Mimir集群

# 基础认证信息（按需配置）
remote_write_username = "存储系统用户名"
remote_write_password = "存储系统密码" # 敏感参数会自动加密
```

### 配置示例
1. VictoriaMetrics 单节点模式：
```hcl
module "eks_cluster" {
  remote_write_url      = "http://vm-single:8428/api/v1/write"
  remote_write_username = "vmuser"
  remote_write_password = "vmpass123"
}
```

2. Mimir 分布式集群：
```hcl
module "eks_cluster" {
  remote_write_url      = "http://mimir-distributor:9009/api/v1/push"
  remote_write_username = "tenant-1"  
  remote_write_password = "mimir@2024"
}
```

### 使用注意事项
1. TLS加密建议（生产环境必选）：
   - 为`remote_write_url`配置HTTPS端点
   - 在Kubernetes中配置对应的证书Secret

2. 网络策略：
   - 确保EKS工作节点可以访问监控存储系统的服务端口
   - 建议通过VPC Peering或PrivateLink建立私有连接

3. 敏感信息处理：
   - `remote_write_password`变量会自动标记为sensitive
   - 建议通过AWS Secrets Manager管理密码
```

当前配置已支持：
✅ 多存储系统兼容（VictoriaMetrics/Mimir）
✅ 基础认证机制
✅ 敏感信息加密处理
✅ Helm chart参数自动注入

        