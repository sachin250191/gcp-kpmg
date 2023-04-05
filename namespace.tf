resource "google_kubernetes_engine_namespace" "my-namespace" {
  name = var.namespace_name
}
