provider "aws" {
region = "us-east-1"
 }
resource "aws_instance" "NAT" {
  ami           = "ami-0422d936d535c63b1"
  instance_type = "t2.micro"
  security_groups = [
        "sg-075c4b674d14b6897"
    ]
  subnet_id = "subnet-0065df4d2343952b5"
  key_name = "fullstack"
  tags {
    Name = "NAT"
  }
}

resource "aws_route" "r" {
  route_table_id = "rtb-06a5072da8d473a31"
  destination_cidr_block    = "0.0.0.0/0"
  instance_id = "${aws_instance.NAT.id}"
}

