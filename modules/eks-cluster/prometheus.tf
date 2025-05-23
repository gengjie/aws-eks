resource "helm_release" "prometheus" {
  count        = var.prometheus_enabled ? 1 : 0
  name         = "prometheus"
  repository   = "https://prometheus-community.github.io/helm-charts"
  chart        = "kube-prometheus-stack"
  namespace    = "monitoring"
  version      = "48.1.1"
  create_namespace = true

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.remoteWrite[0].url"
    value = var.remote_write_url
  }

  set {
    name  = "prometheus.prometheusSpec.remoteWrite[0].basicAuth.username"
    value = var.remote_write_username
  }

  set_sensitive {
    name  = "prometheus.prometheusSpec.remoteWrite[0].basicAuth.password"
    value = var.remote_write_password
  }
}

resource "kubernetes_manifest" "servicemonitor" {
  count = var.prometheus_enabled ? 1 : 0
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata" = {
      "name"      = "default-monitor"
      "namespace" = "monitoring"
    }
    "spec" = {
      "endpoints" = [{
        "interval" = "30s"
        "port"     = "web"
      }]
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/name" = "service-monitor"
        }
      }
    }
  }
}