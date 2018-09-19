# Create Security Group & Bastion Host to access private subnet
provider "aws" {
region = "us-east-1"
 }
 resource "aws_security_group" "bh_rule" {
  name        = "bh_prod_rule"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-04186de44db3095fa"

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
resource "aws_instance" "BHprod" {
  ami           = "ami-6871a115"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
        "${aws_security_group.bh_rule.id}"    ]
  subnet_id = "subnet-00d193a4d3d04e6d9"
  key_name = "fullstack"
  tags {
    Name = "BHprod"
  }
}  
