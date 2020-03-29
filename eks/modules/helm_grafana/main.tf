data "helm_repository" "stable" {
    name = "stable"
    url = "https://kubernetes-charts.storage.googleapis.com"
}

# secret for Grafana Authentication
resource "kubernetes_secret" "azuread_auth" {
    metadata {
        name = "grafana-secret"
        namespace = "monitoring"
    }
    data = {
        GF_AUTH_AZUREAD_CLIENT_ID = var.azuread_client_id
        GF_AUTH_AZUREAD_CLIENT_SECRET = var.azuread_client_secret
    }
    type = "Opaque"
}

resource "helm_release" "grafana" {
    name = "grafana"
    chart = "grafana"
    namespace = "monitoring"
    repository = data.helm_repository.stable.metadata[0].name
    recreate_pods = true
    set_string {
        name = "ingress.hosts.0"
        value = "grafana.${var.environment}.${var.domain}"
    }
    set_string {
        name = "grafana\\.ini.server.domain"
        value = "grafana.${var.environment}.${var.domain}"
    }
    set_string {
        name = "grafana\\.ini.server.root_url"
        value = "https://grafana.${var.environment}.${var.domain}"
    }
    values = [
        file("${path.module}/values.yaml")
    ]
}