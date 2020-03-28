data "aws_caller_identity" "current" {}

data "helm_repository" "stable" {
    name = "stable"
    url = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "cluster-autoscaler" {
    name = "cluster-autoscaler"
    chart = "cluster-autoscaler"
    repository = data.helm_repository.stable.metadata[0].name
    namespace = "kube-system"
    # has to match k8s version: https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler#releases
    set_string {
        name = "image.tag"
        #value = "v1.15.5" (didnt work even though K8S 1.15)
        value = "v1.14.7"
    }
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
    # has to match the prometheus-operator instance name
    # kubectl get servicemonitor -n monitoring
    set_string {
        name = "serviceMonitor.selector.prometheus"
        value = "prometheus-operator-prometheus"
    }
    set_string {
        name = "serviceMonitor.selector.release"
        value = "promop"
    }
    values = [
        file("${path.module}/cluster-autoscaler-chart-values.yaml")
    ]
}