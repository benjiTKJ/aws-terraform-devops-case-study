# Public hosted zone for routing traffic
resource "aws_route53_zone" "route53_public" {
  name     = var.domain
  comment  = "Public hosted zone for domain" 
}


/**
# Route 53 Latency Record for Singapore
data "aws_lb" "sg_eks_alb" {
  provider = aws.ap-southeast-1
  arn      = var.sg_eks_alb_arn
}

resource "aws_route53_record" "sg_latency_record" {
  zone_id = aws_route53_zone.route53_public.zone_id
  name    = "www.${var.domain}"  
  type    = "A"

  alias {
    name                   = data.aws_lb.sg_eks_alb.dns_name
    zone_id                = data.aws_lb.sg_eks_alb.zone_id
    evaluate_target_health = false
  }

  set_identifier = "AP-SOUTHEAST-1"
  latency_routing_policy {
    region = var.sg_region
  }
}

# Route 53 Latency Record for US
data "aws_lb" "us_eks_alb" {
  provider = aws.us-east-1
  arn      = var.us_eks_alb_arn
}

resource "aws_route53_record" "us_latency_record" {
  zone_id = aws_route53_zone.route53_public.zone_id
  name    = "www.${var.domain}"  
  type    = "A"

  alias {
    name                   = data.aws_lb.us_eks_alb.dns_name
    zone_id                = data.aws_lb.us_eks_alb.zone_id
    evaluate_target_health = false
  }

  set_identifier = "US-EAST-1"
  latency_routing_policy {
    region = var.us_region
  }
}
**/
