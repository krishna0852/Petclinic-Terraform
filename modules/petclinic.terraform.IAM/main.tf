resource "aws_iam_role" "ecs-security" {
  name = "ecs-execution-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = data.template_file.get.rendered
  inline_policy {
    name="ecstaskexecutionrole"
    policy=data.template_file.taskexecutionpolicy.rendered
  }

  tags = {
    tag-key = "ECS-task-role"
  }
}

data "template_file" "get" {
  template = "${file("${path.module}/assumerole.json")}"
 
}

data "template_file" "taskexecutionpolicy"{
    template = "${file("${path.module}/ecstaskexecutionrole.json")}"
  #    vars = {
  #       arn=var.task-arn
  # }
}