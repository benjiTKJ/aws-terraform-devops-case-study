data "aws_acm_certificate" "main" {
    provider    = aws.ap-southeast-1  
    domain      = var.cert_domain
    types       = ["AMAZON_ISSUED"]
    most_recent = true
}

data "aws_acm_certificate" "main" {
    provider    = aws.us-east-1
    domain      = var.cert_domain
    types       = ["AMAZON_ISSUED"]
    most_recent = true
}