# Create NAT instance in Prod subnet with Prod security Group
provider "aws" {
region = "us-east-1"
 }
resource "aws_instance" "NATProd" {
  ami           = "ami-0422d936d535c63b1"
  instance_type = "t2.micro"
  security_groups = [
        "sg-01006c8ba9d6d2bf3"
    ]
  subnet_id = "subnet-00d193a4d3d04e6d9"
  key_name = "fullstack"
  tags {
    Name = "NATProd"
  }
}

resource "aws_route" "r" {
  route_table_id = "rtb-035dde7ba7da45780"
  destination_cidr_block    = "0.0.0.0/0"
  instance_id = "${aws_instance.NATProd.id}"
}
