# Create Security Group & Bastion Host to access private subnet
provider "aws" {
region = "us-east-1"
 }
 resource "aws_security_group" "wp_rule" {
  name        = "wp_test_rule"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-07630dbe87d48cf95"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["198.207.185.100/32"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
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
resource "aws_instance" "wptest" {
  ami           = "ami-0a950ca991c6c754b"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
        "${aws_security_group.wp_rule.id}"    ]
  subnet_id = "subnet-0ba094040ff3c4e5b"
  key_name = "fullstack"
  tags {
    Name = "wptest"
  }
}  
