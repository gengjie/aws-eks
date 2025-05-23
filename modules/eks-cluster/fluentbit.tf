resource "kubernetes_config_map" "fluentbit" {
  metadata {
    name      = "fluentbit-config"
    namespace = "kube-system"
  }

  data = {
    "fluent-bit.conf" = <<-EOT
    [SERVICE]
        Flush        1
        Log_Level    info

    @INCLUDE input-kubernetes.conf
    @INCLUDE filter-kubernetes.conf
    @INCLUDE output-es.conf
    EOT

    "input-kubernetes.conf" = <<-EOT
    [INPUT]
        Name              tail
        Tag               kube.*
        Path              /var/log/containers/*.log
        Parser            docker
        DB                /var/log/flb_kube.db
        Mem_Buf_Limit     5MB
        Skip_Long_Lines   On
    EOT

    "output-es.conf" = <<-EOT
    [OUTPUT]
        Name            es
        Match           *
        Host            ${var.elasticsearch_endpoint}
        Port            9200
        Logstash_Format On
        Replace_Dots    On
        HTTP_User       ${jsondecode(var.elasticsearch_auth).username}
        HTTP_Passwd     ${jsondecode(var.elasticsearch_auth).password}
    EOT
  }
}

resource "kubernetes_daemonset" "fluentbit" {
  metadata {
    name      = "fluentbit"
    namespace = "kube-system"
  }

  spec {
    selector {
      match_labels = {
        "k8s-app" = "fluentbit"
      }
    }

    template {
      metadata {
        labels = {
          "k8s-app" = "fluentbit"
        }
      }

      spec {
        service_account_name = "fluentbit"
        
        container {
          name  = "fluentbit"
          image = "fluent/fluent-bit:2.1.0"
          
          volume_mount {
            name       = "config"
            mount_path = "/fluent-bit/etc/"
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.fluentbit.metadata[0].name
          }
        }
      }
    }
  }
}