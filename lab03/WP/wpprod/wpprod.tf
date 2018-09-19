# Create Security Group & Bastion Host to access private subnet
provider "aws" {
region = "us-east-1"
 }
 resource "aws_security_group" "wp_rule" {
  name        = "wp_prod_rule"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-04186de44db3095fa"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["198.207.185.100/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}
resource "aws_instance" "wpprod" {
  ami           = "ami-6871a115"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
        "${aws_security_group.wp_rule.id}"    ]
  subnet_id = "subnet-00d193a4d3d04e6d9"
  key_name = "fullstack"
  count = 2
  tags {
    Name = "wpprod"
  }
}  
