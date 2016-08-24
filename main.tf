resource "aws_instance" "server" {
    ami                  = "${lookup(var.ami, "${var.region}")}"
    instance_type        = "${var.instance_type}"
    key_name             = "${var.key_name}"
    count                = "${var.servers}"
#    security_groups = ["${aws_security_group.consul.name}"]
    #security_groups = ["allow_ssh"]
    subnet_id            = "subnet-6e101446"
    #iam_instance_profile = "AmazonECSContainerInstanceRole"
    iam_instance_profile = "${aws_iam_instance_profile.ecs_test_profile.name}"
    depends_on           = ["aws_iam_instance_profile.ecs_test_profile"]
    user_data = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.lunchbot.name} >> /etc/ecs/ecs.config
    EOF
    connection {
        user = "${lookup(var.user, var.platform)}"
        key_file = "${var.key_path}"
    }

    #Instance tags
    tags {
        Name = "${var.tagName}-${count.index}"
    }
}

resource "aws_ecs_cluster" "lunchbot" {
  name = "infra-services"
}
