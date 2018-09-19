provider "aws" {
  region = "us-east-1"

}

resource "aws_security_group" "wordpress_rule" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-04186de44db3095fa"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}
resource "aws_instance" "wordpress_terraform" {
  ami           = "ami-04169656fea786776"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
        "${aws_security_group.wordpress_rule.id}"
    ]
  key_name = "fullstack"
  tags {
    Name = "wordpress_terraform"
  }
  provisioner "remote-exec" {
    inline = [
      "hostname -f"    
    ]
    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key  = "${file("~/Downloads/fullstack.pem")}"
  }
  }
  
   provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.wordpress_terraform.public_ip}, install-wordpress.yml -b"
  }
}
