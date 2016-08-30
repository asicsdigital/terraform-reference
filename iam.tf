data "aws_iam_policy_document" "ecs_cluster_example" {
    statement {
      actions = [
        "ecs:Describe*",
        "ecs:List*"
        ]
      resources = ["*"]
    }
    statement {
      actions = [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecs:DescribeContainerInstances",
        "ecs:DescribeTasks",
        "ecs:UpdateContainerAgent",
        "ecs:StartTask",
        "ecs:StopTask",
        "ecs:RunTask"
      ]
      resources = [
          "arn:aws:ecs:us-east-1:691803950817:cluster/${aws_ecs_cluster.lunchbot.name}"
      ]
    }

}


resource "aws_iam_role_policy" "lunchbot" {
    name   = "ecs_example_policy"
    role   = "${aws_iam_role.lunchbot_role.id}"
    policy = "${data.aws_iam_policy_document.ecs_cluster_example.json}"
}

resource "aws_iam_role" "lunchbot_role" {
    name               = "ecs_test_role"
    path               = "/"
    #assume_role_policy = "${data.aws_iam_policy_document.ecs_cluster_example.json}"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]

      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

/*
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
*/

resource "aws_iam_instance_profile" "ecs_test_profile" {
    name = "ecs_test_profile"
    roles = ["${aws_iam_role.lunchbot_role.name}"]
}
