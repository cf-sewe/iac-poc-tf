data "aws_caller_identity" "current" {}

provider "helm" {
    kubernetes {
        config_path = "${path.root}/kubeconfig_${var.cluster_name}"
    }
}

data "helm_repository" "stable" {
    name = "stable"
    url = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "cluster-autoscaler" {
    name = "cluster-autoscaler"
    chart = "cluster-autoscaler"
    repository = data.helm_repository.stable.metadata[0].name
    version = "7.1.0"
    namespace = "kube-system"
    set_string {
        name = "awsRegion"
        value = var.region
    }
    set_string {
        name = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
        value = "arn:aws:iam::${var.account_id}:role/cluster-autoscaler"
    }
    set_string {
        name = "autoDiscovery.clusterName"
        value = var.cluster_name
    }
    values = [
        file("${path.module}/cluster-autoscaler-chart-values.yaml")
    ]
}