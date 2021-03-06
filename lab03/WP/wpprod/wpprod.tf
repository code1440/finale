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
  image_id      = "ami-0a950ca991c6c754b"
  instance_type = "t2.micro"
  key_name 	= "fullstack"
  security_groups = ["sg-04adc18ebe624bf24"]
  associate_public_ip_address = "false"
  
}

resource "aws_autoscaling_group" "wp" {
  max_size                  = 5
  min_size                  = 2
  launch_configuration = "${aws_launch_configuration.wp.name}"
  health_check_type         = "ELB"
  vpc_zone_identifier       = ["subnet-00d193a4d3d04e6d9"]
  load_balancers = ["${aws_elb.wp.name}"]
}
