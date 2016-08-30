###


###

resource "aws_iam_instance_profile" "ecs_test_profile" {
    name = "ecs_test_profile"
    roles = ["${aws_iam_role.lunchbot_role.name}"]
}


###


resource "aws_iam_role" "lunchbot_role" {
    name               = "ecs_lunchbot_role"

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

resource "aws_iam_policy" "ecs-lunchbot-policy" {
    name        = "ecs-lunchbot-policy"
    description = "A test policy for ECS slack lunchbot"
    policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "ecs:CreateCluster",
          "ecs:RegisterContainerInstance",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Submit*",
          "ecs:Poll"
        ],
        "Resource": [
          "*"
        ]
      }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach-lunchbot" {
  name       = "lunchbot-attachment"
  roles      = ["${aws_iam_role.lunchbot_role.name}"]
  policy_arn = "${aws_iam_policy.ecs-lunchbot-policy.arn}"
}
