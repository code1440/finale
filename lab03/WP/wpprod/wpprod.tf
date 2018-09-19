provider "aws" {
  region     = "us-east-1"
}
resource "aws_elb" "wp" {
  name               = "elb"
  subnets	      = ["subnet-00d193a4d3d04e6d9","subnet-0c6b0649641900769"]
  #availability_zones  = ["us-east-1f", "us-east-1e"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  tags {
    Name = "TejasELB"
  }
}

data "template_file" "wp" {
  template = "${file("${path.module}/init.tpl")}"

  vars {
    databasedns = "${aws_db_instance.wordpressdb.endpoint}"
  }
  vars {
    lbdns = "${aws_elb.wp.dns_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "up" {
  alarm_name          = "up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.wp.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.up.arn}"]
}

resource "aws_autoscaling_policy" "up" {
  name                   = "UPpolicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 180
  autoscaling_group_name = "${aws_autoscaling_group.wp.name}"
}


resource "aws_cloudwatch_metric_alarm" "down" {
  alarm_name          = "down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.wp.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.down.arn}"]
}

resource "aws_autoscaling_policy" "down" {
  name                   = "Downpolicy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 180
  autoscaling_group_name = "${aws_autoscaling_group.wp.name}"
}


resource "aws_launch_configuration" "wp" {
  image_id      = "ami-04169656fea786776"
  instance_type = "t2.micro"
  key_name 	= "fullstack"
  security_groups = ["sg-04adc18ebe624bf24"]
  associate_public_ip_address = "false"
  user_data = "${data.template_file.wp.rendered}"
}

resource "aws_autoscaling_group" "wp" {
  max_size                  = 5
  min_size                  = 1
  launch_configuration = "${aws_launch_configuration.wp.name}"
  health_check_type         = "ELB"
  vpc_zone_identifier       = ["subnet-00d193a4d3d04e6d9"]
  load_balancers = ["${aws_elb.wp.name}"]
  

}


resource "aws_instance" "bastion" {
  count = 1
  ami           = "ami-6871a115"
  instance_type = "t2.micro"
  subnet_id     = "subnet-00d193a4d3d04e6d9"
  key_name      = "fullstack"

  provisioner "file" {
    source      = "~/Downloads/fullstack.pem"
    destination = "~/.ssh/fullstack.pem"
    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("~/Downloads/fullstack.pem")}"
    }
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("~/.ssh/fullstack.pem")}"
    }
    inline = [
      "chmod 400 ~/.ssh/fullstack.pem",
    ]
  }

  tags {
    Name = "bastion_host_tejas"
  }
} 


output "endpoint_for_wpdb" {
  value = "${aws_db_instance.wordpressdb.endpoint}"
}

resource "aws_db_instance" "wordpressdb" {
  identifier = "dbinstance"
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "wordpress"
  username             = "wordpress"
  password             = "wordpress"
  db_subnet_group_name = "${aws_db_subnet_group.wp.id}"
  skip_final_snapshot     = "true"

  tags {
    Name = "tejasdb"
  }

}
resource "aws_db_subnet_group" "wp" {
  name       = "wp"
  subnet_ids = ["subnet-00d193a4d3d04e6d9","subnet-0c6b0649641900769"]

  tags {
    Name = "tejas"
  }
}
