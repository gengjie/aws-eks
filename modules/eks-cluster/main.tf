module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  cluster_endpoint_public_access = true

  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type        = "ingress"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      cidr_blocks = [var.vpc_cidr]
    }
  }

  enable_irsa = true
}

resource "aws_route53_record" "eks_endpoint" {
  zone_id = var.hosted_zone_id
  name    = var.cluster_domain
  type    = "CNAME"
  ttl     = 300
  records = [module.eks.cluster_endpoint]
}