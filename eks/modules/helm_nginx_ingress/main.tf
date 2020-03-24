provider "helm" {
    kubernetes {
        config_path = "${path.root}/kubeconfig_${var.cluster_name}"
    }
}

data "helm_repository" "stable" {
    name = "stable"
    url = "https://kubernetes-charts.storage.googleapis.com"
}

# todo:
# - nginx as DaemonSet (?)
# - influence network selection?
resource "helm_release" "nginx-ingress" {
    name = "nginx-ingress"
    chart = "nginx-ingress"
    repository = data.helm_repository.stable.metadata[0].name
    namespace = "kube-system"
    set {
        name = "prometheus.create"
        value = true
    }
}