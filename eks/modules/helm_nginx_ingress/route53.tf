# generate wildcard domain (e.g. *.test.cplace.xyz)
#   this domain redirects to the LB IPs
# generate wildcard certificate

# get ingress controller to access the external LB-DNS name
data "kubernetes_service" "ingress" {
    metadata {
        name = "nginx-ingress-controller"
        namespace = "kube-system"
    }
    depends_on = [helm_release.nginx_ingress]
}

# get zone_id , dns_name for use in domain alias
#data "aws_elb" "ingress" {
#  # a85cc392e2f3c433882171ceb76721de-1121462615.eu-west-1.elb.amazonaws.com. -> a85cc392e2f3c433882171ceb76721de
#  name = trimsuffix(data.kubernetes_service.ingress.load_balancer_ingress.0.hostname, "-")
#}

data "aws_elb_hosted_zone_id" "this" {}

data "aws_route53_zone" "this" {
    name = var.domain
    private_zone = false
}

# create wilcard dns entr, directing to ELB
resource "aws_route53_record" "wildcard" {
    zone_id = data.aws_route53_zone.this.zone_id
    name = "*.${var.environment}.${var.domain}"
    type = "A"
    alias {
        name = data.kubernetes_service.ingress.load_balancer_ingress.0.hostname
        zone_id = data.aws_elb_hosted_zone_id.this.id
        evaluate_target_health = true
    }
}