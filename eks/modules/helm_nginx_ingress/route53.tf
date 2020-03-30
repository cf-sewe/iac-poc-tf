# generate wildcard domain (e.g. *.test.cplace.xyz)
#   this domain redirects to the LB IPs

# TODO: Check if there is a better way to get the LB hostname for the DNS record
# the current implementation leads to refresh of 'resource "aws_route53_record" "wildcard"' everytime

# get ingress controller to access the external LB-DNS name
data "kubernetes_service" "ingress" {
    metadata {
        name = "nginx-ingress-controller"
        namespace = "kube-system"
    }
    depends_on = [
        helm_release.nginx_ingress
    ]
}

# for AWS ELB Classic Loadbalancer
#data "aws_elb_hosted_zone_id" "this" {}

# for AWS NLB
data "aws_lb" "this" {
    # ac7b39bc8d34d49b49fbde6d7659a384-f307f875bc624fb5.elb.eu-west-1.amazonaws.com -> ac7b39bc8d34d49b49fbde6d7659a384
    name = substr(data.kubernetes_service.ingress.load_balancer_ingress.0.hostname, 0, 32)
}

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
        # ELB
        #name = data.kubernetes_service.ingress.load_balancer_ingress.0.hostname
        #zone_id = data.aws_elb_hosted_zone_id.this.id
        # NLB
        name = data.aws_lb.this.dns_name
        zone_id = data.aws_lb.this.zone_id
        evaluate_target_health = true
    }
}