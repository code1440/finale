# Create NAT instance in DEV subnet with dev security Group
provider "aws" {
region = "us-east-1"
 }
resource "aws_instance" "NATDev" {
  ami           = "ami-0422d936d535c63b1"
  instance_type = "t2.micro"
  security_groups = [
        "sg-075c4b674d14b6897"
    ]
  subnet_id = "subnet-0065df4d2343952b5"
  key_name = "fullstack"
  tags {
    Name = "NATDev"
  }
}

resource "aws_route" "r" {
  route_table_id = "rtb-06a5072da8d473a31"
  destination_cidr_block    = "0.0.0.0/0"
  instance_id = "${aws_instance.NATDev.id}"
}

# Create NAT instance in Test subnet with dev security Group
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

# Create NAT instance in Prod subnet with dev security Group
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
  route_table_id = "rtb-02ec857935c9afb7c"
  destination_cidr_block    = "0.0.0.0/0"
  instance_id = "${aws_instance.NATProd.id}"
}
