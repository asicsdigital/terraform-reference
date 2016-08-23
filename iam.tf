data "aws_iam_policy_document" "ecs_cluster_example" {
    statement {
      actions = [
        "ecs:CreateCluster",
        "ecs:RegisterContainerInstance",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Submit*",
        "ecs:Poll"
      ]
      resources = [
          "arn:aws:ecs:us-east-1:691803950817:cluster/${aws_ecs_cluster.lunchbot.name}"
      ]
    }

}

resource "aws_iam_policy" "lunchbot" {
    name = "ecs_example_policy"
    path = "/"
    policy = "${data.aws_iam_policy_document.ecs_cluster_example.json}"
}
