locals {
  domain      = format("qdrant.%s", trimprefix("${var.subdomain}.${var.base_domain}", "."))
  domain_full = format("qdrant.%s.%s", trimprefix("${var.subdomain}.${var.cluster_name}", "."), var.base_domain)

  helm_values = [{
    qdrant = {
      replicaCount = 3

      env = [
        {
          name  = "QDRANT__STORAGE__PERFORMANCE__OPTIMIZER_CPU_BUDGET"
          value = 8
        },
        {
          name  = "QDRANT__STORAGE__PERFORMANCE__MAX_SEARCH_THREADS"
          value = 8
        }

      ]

      ingress = {
        enabled = true
        ingressClassName : ""
        annotations = {
          "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
          "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
          "traefik.ingress.kubernetes.io/router.tls"         = "true"
        }
        hosts = [
          {
            host = local.domain
            paths = [{
              path        = "/"
              servicePort = 6333
            }]
          },
          {
            host = local.domain_full
            paths = [{
              path        = "/"
              servicePort = 6333
            }]
          }
        ]
        tls = [{
          secretName = "qdrant-tls"
          hosts = [
            local.domain,
            local.domain_full,
          ]
        }]
      }

      resources : {
        limits = {
          cpu    = "1000m"
          memory = "1Gi"
        }
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }

      persistence = {
        size = "10Gi"
      }

      config = {
        cluster = {
          enabled : true
        }
      }

      metrics = {
        serviceMonitor = {
          enabled : var.enable_service_monitor
        }
      }

      apiKey         = true
      readOnlyApiKey = true
    }
  }]
}
