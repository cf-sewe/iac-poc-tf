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
    set_string {
        name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
        value = module.acm.this_acm_certificate_arn
    }
    values = [
        file("${path.module}/values.yaml")
    ]
}