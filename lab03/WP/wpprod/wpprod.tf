resource "aws_placement_group" "prod" {
  name     = "prod"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "wpprod" {
  name                      = "wp-terraform-prod"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  placement_group           = "${aws_placement_group.prod.id}"
  launch_configuration      = "${aws_launch_configuration.wp_prod.name}"
  vpc_zone_identifier       = ["subnet-00d193a4d3d04e6d9", "subnet-0c6b0649641900769"]

  initial_lifecycle_hook {
    name                 = "wp_prod"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = <<EOF
{
  "foo": "bar"
}
EOF

    notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }

  tag {
    key                 = "foo"
    value               = "bar"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}

resource "aws_launch_template" "foobar" {
  name_prefix = "foobar"
  image_id = "ami-0a950ca991c6c754b"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "bar" {
  availability_zones = ["us-east-1"]
  desired_capacity = 1
  max_size = 3
  min_size = 1
  launch_template = {
    id = "${aws_launch_template.foobar.id}"
    version = "$$Latest"
  }
}
