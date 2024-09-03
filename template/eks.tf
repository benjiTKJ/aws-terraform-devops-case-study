# Singapore EKS cluster
resource "aws_eks_cluster" "sg_cluster" {
    provider    = aws.ap-southeast-1
    name        = "sg-cluster"
    role_arn    = aws_iam_role.sg_eks_role.arn
    version     = var.eks_version

    vpc_config {
      subnet_ids                = [aws_subnet.sg_tier_2_a.id,aws_subnet.sg_tier_2_b.id]
      endpoint_private_access   = true
      endpoint_public_access    = false
    }
  

    access_config {
        authentication_mode                         = "API"
        bootstrap_cluster_creator_admin_permissions = true
    }

    kubernetes_network_config {
        ip_family           = "ipv4"
    }

    tags = {
        Environment     = var.environment
    }
}

resource "aws_iam_role" "sg_eks_role" {
    provider           = aws.ap-southeast-1
    name               = "sg-eks-cluster-role"
    assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json

    tags = {
        Environment     = var.environment
    }
}

data "aws_iam_policy_document" "sg_eks_assume_role" {
    statement {
      effect = "Allow"
  
      principals {
        type        = "Service"
        identifiers = ["eks.amazonaws.com"]
      }
  
      actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy" "sg_eks_cluster_policy" {
    name = "AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "sg_eks_cluster_policy_attachment" {
  
    role        = aws_iam_role.sg_eks_role.name
    policy_arn  = data.aws_iam_policy.sg_eks_cluster_policy.arn
}

data "aws_iam_policy" "sg_eks_vpc_policy" {
    name = "AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "sg_eks_vpc_policy_attachment" {
  
    role        = aws_iam_role.sg_eks_role.name
    policy_arn  = data.aws_iam_policy.sg_eks_vpc_policy.arn
}

resource "aws_eks_addon" "eks_addon_coredns" {
    provider                    = aws.ap-southeast-1
    cluster_name                = aws_eks_cluster.sg_cluster.name
    addon_name                  = "coredns"
    addon_version               = "v1.11.1-eksbuild.4"
    resolve_conflicts_on_update = "NONE"
    service_account_role_arn    = aws_iam_role.sg_eks_role.arn
}

resource "aws_eks_addon" "eks_addon_kube_proxy" {
    provider                    = aws.ap-southeast-1
    cluster_name                = aws_eks_cluster.sg_cluster.name
    addon_name                  = "kube-proxy"
    addon_version               = "v1.29.0-eksbuild.1"
    resolve_conflicts_on_update = "NONE"
    service_account_role_arn    = aws_iam_role.sg_eks_role.arn
}

resource "aws_eks_addon" "eks_addon_vpc_cni" {
    provider                    = aws.ap-southeast-1
    cluster_name                = aws_eks_cluster.sg_cluster.name
    addon_name                  = "aws-vpc-cni"
    addon_version               = "v1.16.0-eksbuild.1"
    resolve_conflicts_on_update = "NONE"
    service_account_role_arn    = aws_iam_role.sg_eks_role.arn
}

resource "aws_eks_addon" "eks_addon_ebs_csi" {
    provider                    = aws.ap-southeast-1
    cluster_name                = aws_eks_cluster.sg_cluster.name
    addon_name                  = "aws-ebs-csi-driver"
    addon_version               = "v1.28.0-eksbuild.1"
    resolve_conflicts_on_update = "NONE"
    service_account_role_arn    = aws_iam_role.sg_eks_role.arn
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.sg_cluster.version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_node_group" "sg_node_group" {
    provider                = aws.ap-southeast-1
    cluster_name            = aws_eks_cluster.sg_cluster.name
    node_group_name         = "sg-eks-node"
    node_role_arn           = aws_iam_role.sg_eks_node_role.arn
    subnet_ids              = [aws_subnet.sg_tier_2_a.id,aws_subnet.sg_tier_2_b.id]
    ami_type                = "AL2_x86_64"
    capacity_type           = "ON_DEMAND"
    disk_size               = "20"
    instance_types          = ["t3.medium"]
    release_version         = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

    tags = {
        Environment     = var.environment
    }

    scaling_config {
      desired_size = var.eks_node_desired_size
      max_size     = var.eks_node_max_size
      min_size     = var.eks_node_min_size
    }
  
    update_config {
      max_unavailable = 1
    }
    
}

resource "aws_iam_role" "sg_eks_node_role" {
    provider           = aws.ap-southeast-1
    name               = "sg-eks-node-role"
    assume_role_policy = data.aws_iam_policy_document.sg_eks_node_assume_role.json

    tags = {
        Environment     = var.environment
    }
}

data "aws_iam_policy_document" "sg_eks_node_assume_role" {
    source_policy_documents = [data.aws_iam_policy_document.sg_eks_node_main_role.json,
    data.aws_iam_policy_document.sg_eks_oidc_allow_policy_document.json
    ]
}

data "aws_iam_policy_document" "sg_eks_node_main_role" {
    statement {
      effect = "Allow"
  
      principals {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
  
      actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "sg_eks_oidc_allow_policy_document" {
  
    statement {
      effect    = "Allow"
      principals {
        type        = "Federated"
        identifiers = [aws_iam_openid_connect_provider.sg_oidc_provider.arn]
      }
      actions   = [
        "sts:AssumeRoleWithWebIdentity"
      ]
    }
}

resource "aws_iam_openid_connect_provider" "sg_oidc_provider" {
    provider        = aws.ap-southeast-1
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = concat([data.tls_certificate.sg_cluster.certificates.0.sha1_fingerprint], [])
    url             = aws_eks_cluster.sg_cluster.identity.0.oidc.0.issuer
    
    tags = {
      Environment = var.environment
    }
}

data "tls_certificate" "sg_cluster" {
  url = aws_eks_cluster.sg_cluster.identity.0.oidc.0.issuer
}

data "aws_iam_policy" "sg_eks_cni_policy" {
    name = "AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "sg_eks_cni_policy_attachment" {
    provider    = aws.ap-southeast-1
    role        = aws_iam_role.sg_eks_node_role.name
    policy_arn  = data.aws_iam_policy.sg_eks_cni_policy.arn
}

data "aws_iam_policy" "sg_eks_worker_node_policy" {
    name = "AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "sg_eks_worker_node_policy_attachment" {
    provider    = aws.ap-southeast-1
    role        = aws_iam_role.sg_eks_node_role.name
    policy_arn  = data.aws_iam_policy.sg_eks_worker_node_policy.arn
}

data "aws_iam_policy_document" "sg_eks_node_to_ec2_allow_policy_document" {
  
    statement {
      effect    = "Allow"
      actions   = [
        "ec2:CreateVolume",
        "ec2:CreateTags",
        "ec2:CreateSnapshot",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:ModifyVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DeleteVolume",
        "ec2:DeleteTags",
        "ec2:DeleteSnapshot",
        "ec2:RevokeSecurityGroupIngress",
        "shield:GetSubscriptionState",
        "wafv2:GetWebACLForResource",
        "waf-regional:GetWebACLForResource",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeImages",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup",
        "ec2:DeleteSecurityGroup"
      ]
      resources = ["*"]
      condition {
        test        = "ForAnyValue:StringEquals" 
        variable    = "aws:ResourceTag/kubernetes.io/cluster-name"
        values      = "sg-cluster"
      }
    }
}

resource "aws_iam_policy" "sg_eks_node_to_ec2_allow_policy" {
    provider    = aws.ap-southeast-1
    name        = "sg-eks-node-to-ec2"
    path        = "/"
    description = "IAM policy for EKS Node to EC2"
    policy      = data.aws_iam_policy_document.sg_eks_node_to_ec2_allow_policy_document.json
    tags        = {
        Environment     = var.environment
    }
}
  
resource "aws_iam_role_policy_attachment" "sg_eks_node_to_ec2_allow_attachment" {
    provider    = aws.ap-southeast-1
    role        = aws_iam_role.sg_eks_node_role.name
    policy_arn  = aws_iam_policy.sg_eks_node_to_ec2_allow_policy.arn
}

data "aws_iam_policy_document" "sg_eks_node_to_alb_allow_policy_document" {
  
    statement {
      effect    = "Allow"
      actions   = [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:DeregisterTargets"
      ]
      resources = ["*"]
      condition {
        test        = "ForAnyValue:StringEquals" 
        variable    = "aws:ResourceTag/kubernetes.io/cluster-name"
        values      = "sg-cluster"
      }
    }
}

resource "aws_iam_policy" "sg_eks_node_to_alb_allow_policy" {
    provider    = aws.ap-southeast-1
    name        = "sg-eks-node-to-alb"
    path        = "/"
    description = "IAM policy for EKS Node to ALB"
    policy      = data.aws_iam_policy_document.sg_eks_node_to_alb_allow_policy_document.json
    tags        = {
        Environment     = var.environment
    }
}
  
resource "aws_iam_role_policy_attachment" "eks_node_to_alb_allow_attachment" {
    provider    = aws.ap-southeast-1
    role        = aws_iam_role.sg_eks_node_role.name
    policy_arn  = aws_iam_policy.sg_eks_node_to_alb_allow_policy.arn
}

# US EKS cluster
resource "aws_eks_cluster" "us_cluster" {
    provider    = aws.us-east-1
    name        = "us-cluster"
    role_arn    = aws_iam_role.us_eks_role.arn
    version     = var.eks_version

    vpc_config {
      subnet_ids                = [aws_subnet.us_tier_2_a.id,aws_subnet.us_tier_2_b.id]
      endpoint_private_access   = true
      endpoint_public_access    = false
    }
  

    access_config {
        authentication_mode                         = "API"
        bootstrap_cluster_creator_admin_permissions = true
    }

    kubernetes_network_config {
        ip_family           = "ipv4"
    }

    tags = {
        Environment     = var.environment
    }
}

resource "aws_iam_role" "us_eks_role" {
    provider           = aws.us-east-1
    name               = "us-eks-cluster-role"
    assume_role_policy = data.aws_iam_policy_document.us_eks_assume_role.json

    tags = {
        Environment     = var.environment
    }
}

data "aws_iam_policy_document" "us_eks_assume_role" {
    statement {
      effect = "Allow"
  
      principals {
        type        = "Service"
        identifiers = ["eks.amazonaws.com"]
      }
  
      actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy" "us_eks_cluster_policy" {
    name = "AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "us_eks_cluster_policy_attachment" {
  
    role        = aws_iam_role.us_eks_role.name
    policy_arn  = data.aws_iam_policy.us_eks_cluster_policy.arn
}

data "aws_iam_policy" "us_eks_vpc_policy" {
    name = "AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "us_eks_vpc_policy_attachment" {
  
    role        = aws_iam_role.us_eks_role.name
    policy_arn  = data.aws_iam_policy.us_eks_vpc_policy.arn
}

resource "aws_eks_addon" "us_eks_addon_coredns" {
    provider                    = aws.us-east-1
    cluster_name                = aws_eks_cluster.us_cluster.name
    addon_name                  = "coredns"
    addon_version               = "v1.11.1-eksbuild.4"
    resolve_conflicts_on_update = "NONE"
    service_account_role_arn    = aws_iam_role.us_eks_role.arn
}

resource "aws_eks_addon" "us_eks_addon_kube_proxy" {
    provider                    = aws.us-east-1
    cluster_name                = aws_eks_cluster.us_cluster.name
    addon_name                  = "kube-proxy"
    addon_version               = "v1.29.0-eksbuild.1"
    resolve_conflicts_on_update = "NONE"
    service_account_role_arn    = aws_iam_role.us_eks_role.arn
}

resource "aws_eks_addon" "us_eks_addon_vpc_cni" {
    provider                    = aws.us-east-1
    cluster_name                = aws_eks_cluster.us_cluster.name
    addon_name                  = "aws-vpc-cni"
    addon_version               = "v1.16.0-eksbuild.1"
    resolve_conflicts_on_update = "NONE"
    service_account_role_arn    = aws_iam_role.us_eks_role.arn
}

resource "aws_eks_addon" "us_eks_addon_ebs_csi" {
    provider                    = aws.us-east-1
    cluster_name                = aws_eks_cluster.us_cluster.name
    addon_name                  = "aws-ebs-csi-driver"
    addon_version               = "v1.28.0-eksbuild.1"
    resolve_conflicts_on_update = "NONE"
    service_account_role_arn    = aws_iam_role.us_eks_role.arn
}

resource "aws_eks_node_group" "us_node_group" {
    provider                = aws.us-east-1
    cluster_name            = aws_eks_cluster.us_cluster.name
    node_group_name         = "sg-eks-node"
    node_role_arn           = aws_iam_role.us_eks_node_role.arn
    subnet_ids              = [aws_subnet.us_tier_2_a.id,aws_subnet.us_tier_2_b.id]
    ami_type                = "AL2_x86_64"
    capacity_type           = "ON_DEMAND"
    disk_size               = "20"
    instance_types          = ["t3.medium"]
    release_version         = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

    tags = {
        Environment     = var.environment
    }

    scaling_config {
      desired_size = var.eks_node_desired_size
      max_size     = var.eks_node_max_size
      min_size     = var.eks_node_min_size
    }
  
    update_config {
      max_unavailable = 1
    }
}

resource "aws_iam_role" "us_eks_node_role" {
    provider           = aws.us-east-1
    name               = "us-eks-node-role"
    assume_role_policy = data.aws_iam_policy_document.us_eks_node_assume_role.json

    tags = {
        Environment     = var.environment
    }
}

data "aws_iam_policy_document" "us_eks_node_assume_role" {
    source_policy_documents = [data.aws_iam_policy_document.us_eks_node_main_role.json,
    data.aws_iam_policy_document.us_eks_oidc_allow_policy_document.json
    ]
}

data "aws_iam_policy_document" "us_eks_node_main_role" {
    statement {
      effect = "Allow"
  
      principals {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
  
      actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "us_eks_oidc_allow_policy_document" {
  
    statement {
      effect    = "Allow"
      principals {
        type        = "Federated"
        identifiers = [aws_iam_openid_connect_provider.us_oidc_provider.arn]
      }
      actions   = [
        "sts:AssumeRoleWithWebIdentity"
      ]
    }
}

resource "aws_iam_openid_connect_provider" "us_oidc_provider" {
    provider        = aws.us-east-1
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = concat([data.tls_certificate.us_cluster.certificates.0.sha1_fingerprint], [])
    url             = aws_eks_cluster.us_cluster.identity.0.oidc.0.issuer
    
    tags = {
      Environment = var.environment
    }
}

data "tls_certificate" "us_cluster" {
  url = aws_eks_cluster.us_cluster.identity.0.oidc.0.issuer
}

data "aws_iam_policy" "us_eks_cni_policy" {
    name = "AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "us_eks_cni_policy_attachment" {
    provider    = aws.ap-southeast-1
    role        = aws_iam_role.us_eks_node_role.name
    policy_arn  = data.aws_iam_policy.us_eks_cni_policy.arn
}

data "aws_iam_policy" "us_eks_worker_node_policy" {
    name = "AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "us_eks_worker_node_policy_attachment" {
    provider    = aws.ap-southeast-1
    role        = aws_iam_role.us_eks_node_role.name
    policy_arn  = data.aws_iam_policy.us_eks_worker_node_policy.arn
}

data "aws_iam_policy_document" "us_eks_node_to_ec2_allow_policy_document" {
  
    statement {
      effect    = "Allow"
      actions   = [
        "ec2:CreateVolume",
        "ec2:CreateTags",
        "ec2:CreateSnapshot",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:ModifyVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DeleteVolume",
        "ec2:DeleteTags",
        "ec2:DeleteSnapshot",
        "ec2:RevokeSecurityGroupIngress",
        "shield:GetSubscriptionState",
        "wafv2:GetWebACLForResource",
        "waf-regional:GetWebACLForResource",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeImages",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup",
        "ec2:DeleteSecurityGroup"
      ]
      resources = ["*"]
      condition {
        test        = "ForAnyValue:StringEquals" 
        variable    = "aws:ResourceTag/kubernetes.io/cluster-name"
        values      = "us-cluster"
      }
    }
}

resource "aws_iam_policy" "us_eks_node_to_ec2_allow_policy" {
    provider    = aws.us-east-1
    name        = "us-eks-node-to-ec2"
    path        = "/"
    description = "IAM policy for EKS Node to EC2"
    policy      = data.aws_iam_policy_document.us_eks_node_to_ec2_allow_policy_document.json
    tags        = {
        Environment     = var.environment
    }
}
  
resource "aws_iam_role_policy_attachment" "us_eks_node_to_ec2_allow_attachment" {
    provider    = aws.us-east-1
    role        = aws_iam_role.us_eks_node_role.name
    policy_arn  = aws_iam_policy.us_eks_node_to_ec2_allow_policy.arn
}

data "aws_iam_policy_document" "us_eks_node_to_alb_allow_policy_document" {
  
    statement {
      effect    = "Allow"
      actions   = [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:DeregisterTargets"
      ]
      resources = ["*"]
      condition {
        test        = "ForAnyValue:StringEquals" 
        variable    = "aws:ResourceTag/kubernetes.io/cluster-name"
        values      = "us-cluster"
      }
    }
}

resource "aws_iam_policy" "us_eks_node_to_alb_allow_policy" {
    provider    = aws.us-east-1
    name        = "us-eks-node-to-alb"
    path        = "/"
    description = "IAM policy for EKS Node to ALB"
    policy      = data.aws_iam_policy_document.us_eks_node_to_alb_allow_policy_document.json
    tags        = {
        Environment     = var.environment
    }
}
  
resource "aws_iam_role_policy_attachment" "us_eks_node_to_alb_allow_attachment" {
    provider    = aws.us-east-1
    role        = aws_iam_role.us_eks_node_role.name
    policy_arn  = aws_iam_policy.us_eks_node_to_alb_allow_policy.arn
}