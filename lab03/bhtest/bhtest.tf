# Create Security Group & Bastion Host to access private subnet
provider "aws" {
region = "us-east-1"
 }
 resource "aws_security_group" "bh_rule" {
  name        = "bh_test_rule"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-07630dbe87d48cf95"

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
resource "aws_instance" "BHtest" {
  ami           = "ami-6871a115"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
        "${aws_security_group.bh_rule.id}"    ]
  subnet_id = "subnet-0ba094040ff3c4e5b"
  key_name = "fullstack"
  tags {
    Name = "BHtest"
  }
}  
