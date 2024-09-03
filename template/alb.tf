# Singapore NLB for bastion host
resource "aws_lb" "sg_bastion_host_nlb" {
  provider           = aws.ap-southeast-1  
  name               = "sg_bastion_host_nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.sg_bastion_host_nlb_sg.id]
  subnets            = [aws_subnet.sg_tier_1_a.id,aws_subnet.sg_tier_1_b.id]

  enable_deletion_protection = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group" "sg_bastion_host_nlb_sg" {
  provider    = aws.ap-southeast-1
  name        = "sg-bastion-host-asg-sg"
  description = "Security group for SG Bastion host NLB"
  vpc_id      = aws_vpc.sg_vpc.id

  ingress {
    description      = "SSH from specific CIDR"
    from_port        = var.ssh_port
    to_port          = var.ssh_port
    protocol         = "tcp"
    cidr_blocks      = [var.internal_team_cidr]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_listener" "sg_ssh_listener" {
  provider          = aws.ap-southeast-1  
  load_balancer_arn = aws_lb.sg_bastion_host_nlb.arn
  port              = var.ssh_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sg_bastion_host_target_group.arn
  }
}

# US ALB for bastion host
resource "aws_lb" "us_bastion_host_nlb" {
  provider           = aws.us-east-1  
  name               = "us_bastion_host_alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.us_bastion_host_nlb_sg.id]
  subnets            = [aws_subnet.us_tier_1_a.id,aws_subnet.us_tier_1_b.id]

  enable_deletion_protection = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group" "us_bastion_host_nlb_sg" {
  provider    = aws.us-east-1  
  name        = "us-bastion-host-asg-sg"
  description = "Security group for SG Bastion host ALB"
  vpc_id      = aws_vpc.us_vpc.id

  ingress {
    description      = "SSH from specific CIDR"
    from_port        = var.ssh_port
    to_port          = var.ssh_port
    protocol         = "tcp"
    cidr_blocks      = [var.internal_team_cidr]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_listener" "us_ssh_listener" {
  provider          = aws.us-east-1   
  load_balancer_arn = aws_lb.us_bastion_host_nlb.arn
  port              = var.ssh_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.us_bastion_host_target_group.arn
  }
}
