# Singapore Auto Scaling group for Bastion Host
resource "aws_autoscaling_group" "sg_bastion_host_asg" {
  provider            = aws.ap-southeast-1
  desired_capacity    = var.bastion_host_desired_capacity
  max_size            = var.bastion_host_max_capacity
  min_size            = var.bastion_host_min_capacity
  vpc_zone_identifier = [aws_subnet.sg_tier_1_a.id,aws_subnet.sg_tier_1_b.id]
  target_group_arns   = [aws_lb_target_group.sg_bastion_host_target_group.arn]

  launch_template {
    id      = aws_launch_template.sg_bastion_host_launch_template.id
    version = aws_launch_template.sg_bastion_host_launch_template.latest_version
  }
}

resource "aws_launch_template" "sg_bastion_host_launch_template" {
  provider      = aws.ap-southeast-1
  name          = "sg-bastion-host"
  image_id      = data.aws_ami.aws_linux_2023_x86.id
  instance_type = var.bastion_host_instance_type

  network_interfaces {
    security_groups = [aws_security_group.sg_bastion_host_asg_sg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
        Environment = var.environment
    }
  }

 key_name = var.ec2_keypair
}

resource "aws_security_group" "sg_bastion_host_asg_sg" {
  provider    = aws.ap-southeast-1
  name        = "sg-bastion-host-asg-sg"
  description = "Security group for SG Bastion host Auto Scaling Group"
  vpc_id      = aws_vpc.sg_vpc.id

  ingress {
    description      = "SSH from NLB"
    from_port        = var.ssh_port
    to_port          = var.ssh_port
    protocol         = "tcp"
    security_groups = [aws_security_group.sg_bastion_host_alb_sg.id]
    cidr_blocks     = [var.vpc_cidr]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "sg_bastion_host_target_group" {
  provider    = aws.ap-southeast-1
  name     = "sg-bastion-host-target-group"
  port     = var.ssh_port
  protocol = "TCP"
  vpc_id   = aws_vpc.sg_vpc.id

  health_check {
    matcher = 200
    interval= 30
    unhealthy_threshold = 2
    timeout = 5
    healthy_threshold = 2
  }
}

# US Auto Scaling group for Bastion Host
resource "aws_autoscaling_group" "us_bastion_host_asg" {
  provider            = aws.us-east-1
  desired_capacity    = var.bastion_host_desired_capacity
  max_size            = var.bastion_host_max_capacity
  min_size            = var.bastion_host_min_capacity
  vpc_zone_identifier = [aws_subnet.us_tier_1_a.id,aws_subnet.us_tier_1_b.id]
  target_group_arns   = [aws_lb_target_group.us_bastion_host_target_group.arn]

  launch_template {
    id      = aws_launch_template.us_bastion_host_launch_template.id
    version = aws_launch_template.us_bastion_host_launch_template.latest_version
  }
}

resource "aws_launch_template" "us_bastion_host_launch_template" {
  provider      = aws.us-east-1
  name          = "us-bastion-host"
  image_id      = data.aws_ami.aws_linux_2023_x86.id
  instance_type = var.bastion_host_instance_type

  network_interfaces {
    security_groups = [aws_security_group.us_bastion_host_asg_sg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
        Environment = var.environment
    }
  }

 key_name = var.ec2_keypair
}

resource "aws_security_group" "us_bastion_host_asg_sg" {
  provider    = aws.us-east-1
  name        = "us-bastion-host-asg-sg"
  description = "Security group for SG Bastion host Auto Scaling Group"
  vpc_id      = aws_vpc.us_vpc.id

  ingress {
    description      = "SSH from NLB"
    from_port        = var.ssh_port
    to_port          = var.ssh_port
    protocol         = "tcp"
    security_groups = [aws_security_group.us_bastion_host_alb_sg.id]
    cidr_blocks     = [var.vpc_cidr]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "us_bastion_host_target_group" {
  provider = aws.us-east-1
  name     = "us-bastion-host-target-group"
  port     = var.ssh_port
  protocol = "TCP"
  vpc_id   = aws_vpc.us_vpc.id

  health_check {
    matcher = 200
    interval= 30
    unhealthy_threshold = 2
    timeout = 5
    healthy_threshold = 2
  }
  
}