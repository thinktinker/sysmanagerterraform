data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_ami" "amazon2" {
  most_recent = true


  filter {
    name = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }
  owners = ["amazon"]
}
