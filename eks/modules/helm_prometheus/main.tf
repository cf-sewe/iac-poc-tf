data "helm_repository" "stable" {
    name = "stable"
    url = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "prometheus" {
    name = "prometheus"
    chart = "prometheus"
    namespace = "monitoring"
    repository = data.helm_repository.stable.metadata[0].name
    set_string {
        name = "nodeExporter.image.tag"
        value = "latest"
    }
    set_string {
        name = "server.image.tag"
        value = "latest"
    }
    #set {
    #    name = "pushgateway.enabled"
    #    value = false
    #}
}