# Create Security Group & Bastion Host to access private subnet
provider "aws" {
region = "us-east-1"
 }
 resource "aws_security_group" "bastion_host_rule" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-08ccb45a1f7489582"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}
resource "aws_instance" "BHDEV" {
  ami           = "ami-6871a115"
  instance_type = "t2.micro"
  security_groups = [
        "bastion_host_rule"    ]
  subnet_id = "subnet-0065df4d2343952b5"
  key_name = "fullstack"
  tags {
    Name = "BHDev"
  }
}

