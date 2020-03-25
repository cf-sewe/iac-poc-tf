provider "helm" {
    kubernetes {
        config_path = "${path.root}/kubeconfig_${var.cluster_name}"
    }
}

data "helm_repository" "stable" {
    name = "stable"
    url = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "grafana" {
    name = "grafana"
    chart = "grafana"
    namespace = "monitoring"
    repository = data.helm_repository.stable.metadata[0].name
    recreate_pods = true
    # grafana version
    set {
        name = "image.tag"
        value = "6.7.1"
    }
    set {
        name = "ingress.enabled"
        value = true
    }
    set {
        name = "ingress.hosts"
        value = "{grafana.${var.environment}.${var.domain}}"
    }
    set_string {
        name = "ingress.annotations.kubernetes\\.io/ingress\\.class"
        value = "nginx"
    }
    set_string {
        name = "ingress.path"
        value = "/"
    }
}