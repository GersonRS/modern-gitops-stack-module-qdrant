locals {
  domain      = format("qdrant.%s", trimprefix("${var.subdomain}.${var.base_domain}", "."))
  domain_full = format("qdrant.%s.%s", trimprefix("${var.subdomain}.${var.cluster_name}", "."), var.base_domain)

  helm_values = [{
    qdrant = {}
  }]
}
