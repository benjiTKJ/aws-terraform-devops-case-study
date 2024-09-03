data "aws_ami" "aws_linux_2023_x86" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["al2023-*-x86_64"]
  }
}