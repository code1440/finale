# Create NAT instance in Test subnet with Test security Group
provider "aws" {
region = "us-east-1"
 }
resource "aws_instance" "NATTest" {
  ami           = "ami-0422d936d535c63b1"
  instance_type = "t2.micro"
  security_groups = [
        "sg-0345b320edb8d2837"
    ]
  subnet_id = "subnet-0ba094040ff3c4e5b"
  key_name = "fullstack"
  tags {
    Name = "NATTest"
  }
}

resource "aws_route" "r" {
  route_table_id = "rtb-0183011f75a609f53"
  destination_cidr_block    = "0.0.0.0/0"
  instance_id = "${aws_instance.NATTest.id}"
}
