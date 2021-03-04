resource "kubernetes_namespace" "ns" {
  count = length(var.k8s_namespaces)
  metadata {
    name = element(var.k8s_namespaces, count.index)
    labels = {
      role            = element(var.k8s_namespaces, count.index)
      istio-injection = "enabled"
    }
  }

  depends_on = [
    google_container_cluster.gke-cluster,
    google_container_node_pool.np-gke-basic,
    google_container_node_pool.np-gke-gpu
  ]
}


resource "kubernetes_network_policy" "block-all" {
  count = length(var.k8s_namespaces)
  metadata {
    name      = "block-all-ingress-traffic"
    namespace = element(var.k8s_namespaces, count.index)
  }

  # deny all ingress traffic
  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }

  depends_on = [
    kubernetes_namespace.ns
  ]
}
