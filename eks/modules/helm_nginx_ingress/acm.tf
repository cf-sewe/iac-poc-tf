# generate wildcard certificate which is assigned to1

module "acm" {
    source = "terraform-aws-modules/acm/aws"
    domain_name = var.domain
    #zone_id = data.aws_elb_hosted_zone_id.this.id
    # defined in route53.tf
    zone_id = data.aws_route53_zone.this.zone_id
    subject_alternative_names = [
        "*.${var.environment}.${var.domain}",
    ]
    tags = {
        Name = "wildcard certificate"
        Environment = "${var.environment}"
        ManagedBy = "terraform"
    }
}

# output: module.acm.this_acm_certificate_arn