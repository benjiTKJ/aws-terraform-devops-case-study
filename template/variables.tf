variable "sg_region" {
    description = "Region of the AWS resources deployed in SG"
    default = "ap-southeast-1"
}

variable "us_region" {
    description = "Region of the AWS resources deployed in US"
    default = "us-east-1"
}

variable "vpc_cidr" {
    description = "CIDR range for VPC with 65,024 available IP address"
    default = "10.0.0.0/16"
}

variable "vpc_enable_dns_hostnames" {
    description = "Allow or deny dns hostnames to VPC"
    default = true
}

variable "environment" {
    description = "Environment name"
    default = "staging"
}

variable "all_access_cidr" {
    description = "CIDR range of all public IP address"
    default = "0.0.0.0/0"
}

variable "tier_1_a_cidr" {
    description = "CIDR range of public subnet 1a with 2,032 available IP address"
    default = "10.0.0.0/21"
}

variable "tier_1_b_cidr" {
    description = "CIDR range of public subnet 1b with 2,032 available IP address"
    default = "10.0.8.0/21"
}

variable "sg_availability_zones" {
    description = "List of availability zones in SG"
    type    = list
    default = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "us_availability_zones" {
    description = "List of availability zones in SG"
    type    = list
    default = ["us-east-1a", "us-east-1b", "us-east-1c","us-east-1d","us-east-1e","us-east-1f"]
}

variable "tier_2_a_cidr" {
    description = "CIDR range of private subnet 2a with 2,032 available IP address"
    default = "10.0.24.0/21"
}

variable "tier_2_b_cidr" {
    description = "CIDR range of private subnet 2b with 2,032 available IP address"
    default = "10.0.32.0/21"
}

variable "bastion_host_desired_capacity" {
    description = "Desired capacity for bastion host ASG"
    default = "1"
}

variable "bastion_host_max_capacity" {
    description = "Max capacity for bastion host ASG"
    default = "1"
}

variable "bastion_host_min_capacity" {
    description = "Min capacity for bastion host ASG"
    default = "1"
}

variable "bastion_host_instance_type" {
    description = "EC2 instance type for bastion host"
    default = "t3.medium"
}

variable "ec2_keypair" {
    description = "EC2 keypair name to use to SSH into EC2 server"
    default = "ec2-user"
}

variable "http_port" {
    description = "Defined http port"
    default = "80"
}

variable "https_port" {
    description = "Defined https port"
    default = "443"
}

variable "ssh_port" {
    description = "Defined SSH port"
    default = "22"
}

variable "rds_port" {
    description = "Defined RDS port"
    default = "5432"
}

variable "all_access_cidr" {
    description = "CIDR range of all public IP address"
    default = "0.0.0.0/0"
}

variable "eks_version" {
    description = "Version of EKS master"
    default = "1.30" 
}

variable "eks_node_desired_size" {
    description = "Desired instance count of EKS node group"
    default = "1"
}

variable "eks_node_max_size" {
    description = "Max instance count of EKS node group"
    default = "1"
}

variable "eks_node_min_size" {
    description = "Min instance count of EKS node group"
    default = "1"
}

variable "domain" {
    description = "Domain name"
    default = "*.test123.com"
}

variable "cert_domain" {
    description = "Cert Domain name"
    default = "*.test123.com"
}

variable "rds_storage" {
    description = "Storage amount for RDS"
    default = "50"
}

variable "rds_name" {
    description = "Database name"
    default = "testdb"
}

variable "rds_engine_version" {
    description = "Database engine version"
    default = "15.0"
}

variable "rds_instance_size" {
    description = "Database engine version"
    default = "15.0"
}

variable "rds_username" {
    description = "Database master username"
    default = "dbadmin"
}

variable "internal_team_cidr" {
    description = "CIDR range of internal team IP addresses"
    default = "65.78.254.57/32"
}

variable "sg_eks_alb_arn" {
    description = "ARN of EKS ALB in SG"
    default = ""
}

variable "us_eks_alb_arn" {
    description = "ARN of EKS ALB in US"
    default = ""
}