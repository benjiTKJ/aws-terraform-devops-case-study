# Problem statement:
[Case Study](case-study.png)

# Assumptions
- S3 bucket to host the TFState file backend have to be created manually before running the first terraform init command
- EC2 keypair have to be created beforehand, or use existing keypair
- Both ap-southeast-1 & us-east-1 will have its own seperate resources (EKS Cluster, bastion host, NLB etc)
- Bastion host is only used to allow internal users access to EKS API (as EKS nodes are in private subnet)
- Once EKS cluster and node group are created, developer will connect to the bastion host via ssh and use kubectl API to create the pods & resources in the EKS worker nodes, and expose the endpoints via EKS ingress in the public subnet. In the ingress annotations, developer can add these:
        - kubernetes.io/ingress.class: alb,
        - alb.ingress.kubernetes.io/scheme: internet-facing,
        - alb.ingress.kubernetes.io/subnets: subnet id of public subnets (SG or US),
        - alb.ingress.kubernetes.io/load-balancer-attributes: 'idle_timeout.timeout_seconds=400,routing.http2.enabled=true',
        - alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80},{"HTTPS": 443}]',
        - alb.ingress.kubernetes.io/inbound-cidrs: "0.0.0.0/0",
        - alb.ingress.kubernetes.io/certificate-arn: certificate arn of production or staging cert (under acm.tf),
        - alb.ingress.kubernetes.io/ssl-policy: "ELBSecurityPolicy-TLS13-1-2-2021-06",
        - alb.ingress.kubernetes.io/healthcheck-port: 'traffic-port',
        - alb.ingress.kubernetes.io/healthcheck-protocol: HTTP,
        - alb.ingress.kubernetes.io/healthcheck-path: "/",
        - alb.ingress.kubernetes.io/healthcheck-interval-seconds: '100',
        - alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5',
        - alb.ingress.kubernetes.io/healthy-threshold-count: '3',
        - alb.ingress.kubernetes.io/target-type: instance,
        - alb.ingress.kubernetes.io/ssl-redirect: '443'
- The above annotations will create an ALB in the public subnet to allow end users to connect to
- Developer will connect to the RDS DB from EKS cluster via specified endpoint and port defined in RDS
- There is no VPC peering connection between SG & US VPC, since architechture design did not specify if resource from SG & US need to talk to each other

# Increasing pod limit to more than 100 for t3.medium
- VPC CNI addon has been included in the cluster
- Update these parameter via kubectl to ensure the setup is complete
```bash
kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true
kubectl set env daemonset aws-node -n kube-system WARM_PREFIX_TARGET=1
kubectl set env daemonset aws-node -n kube-system WARM_IP_TARGET=5
kubectl set env daemonset aws-node -n kube-system MINIMUM_IP_TARGET=2
```

# Domain name for production and staging
Production domain name: https://www.test123.com > this will direct to the EKS endpoint production resource
Staging domain name: https://www.staging.test123.com > this will direct to the EKS endpoint staging resource. This endpoint can further add security group to restrict access by public and only allow internal users.
- Can add the below resource & reference it in the EKS ingress as well as the eks cluster security group 
    - add this annotation:
        - alb.ingress.kubernetes.io/security-groups: security group created below & eks cluster secrurity group,
        - alb.ingress.kubernetes.io/manage-backend-security-group-rules: "false"
```bash
resource "aws_security_group" "staging_access" {
    name        = "staging_access"
    description = "Security group for Staging Ingress"
    vpc_id      = aws_vpc.sg_vpc.id
  
    ingress {
      description      = "HTTPS from Internal"
      from_port        = var.https_port
      to_port          = var.https_port
      protocol         = "tcp"
      cidr_blocks      = [var.internal_team_cidr]
    }

    ingress {
        description      = "HTTP from Internal"
        from_port        = var.http_port
        to_port          = var.http_port
        protocol         = "tcp"
        cidr_blocks      = [var.internal_team_cidr]
      }
  
    tags = {
      Environment = "staging"
    }
}
```
- Since the hosted zone is shared for both ap-southeast-1 & us-east-1, both EKS ALB in ap-southeast-1 and us-east-1 can set the host endpoint to the above production or staging url, then in the route53.tf, uncomment the line 8 onwards and update the arn of both EKS ALBs

# Multi account or shared Route53 hosted zone
- In order to share the hosted zone, this can be done via main account in the AWS organization, creating the public hosted zone (eg route53.tf), while child accounts have the subdomain of the hosted zone

# Run to create resources
```bash
bash run.sh
```