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
resource "helm_release" "nginx_ingress" {
    name = "nginx-ingress"
    chart = "nginx-ingress"
    repository = data.helm_repository.stable.metadata[0].name
    namespace = "kube-system"
    set {
        name = "prometheus.create"
        value = true
    }
    set_string {
        name = "controller.config.server-tokens"
        value = "false"
    }
    # one nginx per k8s node (only makes sense for rather small clusters)
    set_string {
        name = "controller.kind"
        value = "DaemonSet"
    }
    set_string {
        name = "controller.config.default-ssl-certificate"
        value = "kube-system/ingress-nginx"
    }
}