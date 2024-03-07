data "aws_subnets" "getall"{
  filter {
    name = "vpc-id"
    values = [var.vpc-id]
  }
  
}

data "aws_iam_role" "getrole"{
  name=var.iamrole
}



/* ECS-Cluster creation */

resource "aws_ecs_cluster" "cluster"{
    name=var.cluster_name
}

/* ECS-Task definitions */
resource "aws_ecs_task_definition" "container-definition" {
  family                   = var.family-name
  #"petclinic-web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn = data.aws_iam_role.getrole.arn
  
  
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          protocol="tcp"
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

/* ECS service creation and load balancer defining */
resource "aws_ecs_service" "service" {
  name            = "petclinic"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.container-definition.arn
  desired_count   = 1
  launch_type = "FARGATE"
  
  

  /*iam_role        = var.iam-role-arn
  Error: creating ECS Service (petclinic): InvalidParameterException:
   IAM roles are only valid for services configured to use load balancers.*/
  #depends_on      = [aws_iam_role_policy.foo]
   

  network_configuration {
    subnets = length(data.aws_subnets.getall.ids) > 0 ? data.aws_subnets.getall.ids : []
    security_groups = [var.sgid]
    assign_public_ip = true
    
  }
  depends_on = [ aws_ecs_task_definition.container-definition ]
  
  load_balancer {
    target_group_arn = var.tgroup_arn
    container_name   = "nginx"
    container_port   = 80
  }
  
}



/*auto-scaling  --step-scaling*/
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  #depends_on = [ aws_ecs_cluster.cluster ]
}

resource "aws_appautoscaling_policy" "scale-up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 2
    }

    


  }
}

resource "aws_appautoscaling_policy" "scale-down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1  #desired capacity
    }
  }
}



resource "aws_cloudwatch_metric_alarm" "alarm_cpu-high" {
alarm_name = "service_name_-high-cpu"
alarm_description = "Monitors ECS Memory Utilization"

comparison_operator = "GreaterThanOrEqualToThreshold"
evaluation_periods = "2"
metric_name = "CPUUtilization"
namespace = "AWS/ECS"
period = "60"
statistic = "Average"
threshold = 60
//ARN of the policy
alarm_actions = [
aws_appautoscaling_policy.scale-up.arn
]
dimensions = {
"ClusterName" = aws_ecs_cluster.cluster.name
"ServiceName" = aws_ecs_service.service.name
}

}

resource "aws_cloudwatch_metric_alarm" "alarm_cpu-low" {
alarm_name = "service_name_-low-cpu"
alarm_description = "Monitors ECS Memory Utilization"

comparison_operator = "LessThanOrEqualToThreshold"
evaluation_periods = "2"
metric_name = "CPUUtilization"
namespace = "AWS/ECS"
period = "60"
statistic = "Average"
threshold = 50
//ARN of the policy
alarm_actions = [
aws_appautoscaling_policy.scale-down.arn
]
dimensions = {
"ClusterName" = aws_ecs_cluster.cluster.name
"ServiceName" = aws_ecs_service.service.name
}

}



/* Target-scaling */

# resource "aws_appautoscaling_policy" "scale_up-tomemory" {
#   name               = "memory-scale"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.ecs_target.id
#   scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#     }

#     target_value       = 80
#   }
# }

























# resource "aws_appautoscaling_policy" "scale_up-tocpu" {
#   name = "cpu-scale"
#   policy_type = "TargetTrackingScaling"
#   resource_id = aws_appautoscaling_target.dev_to_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.dev_to_target.scalable_dimension
#   service_namespace = aws_appautoscaling_target.dev_to_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }

#     target_value = 60
#   }
# }




 
#   resource "aws_lb_target_group" "target-group" {
#   name     = "tf-example-lb-tg"
#   port     = 80
#   protocol = "HTTP"
#   target_type ="ip"
#   vpc_id   = var.vpc-id
# }


/*getting all subnets*/



# resource "aws_ecs_task_set" "example" {
#   service         = aws_ecs_service.service.id
#   cluster         = aws_ecs_cluster.cluster.id
#   task_definition = aws_ecs_task_definition.container-definition.arn
#   launch_type = "FARGATE"
#   depends_on = [  ]
  

#    network_configuration {
#     subnets = length(data.aws_subnets.getall.ids) > 0 ? data.aws_subnets.getall.ids : []
#     assign_public_ip = true
    
#   }
   
# }

# resource "aws_security_group" "ecs-sg" {
#   name="ecs-sg"
#   vpc_id = var.vpc-id
#   ingress {
#       description = "inbound-traffic"
#       from_port = "80"
#       to_port = "80"
#       protocol = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress{
#       description = "outbound-traffic"
#       from_port = "0"
#       to_port= "0"
#       protocol = "-1" 
#       cidr_blocks = ["0.0.0.0/0"]
#   }
# }




