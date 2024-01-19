/* ECS-Cluster creation */

resource "aws_ecs_cluster" "cluster"{
    name=var.cluster_name
}

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
    security_groups = [aws_security_group.ecs-sg.id]
    assign_public_ip = true
    
  }
  depends_on = [ aws_ecs_task_definition.container-definition ]
}

/*getting all subnets*/
data "aws_subnets" "getall"{
  filter {
    name = "vpc-id"
    values = [var.vpc-id]
  }
  
}

data "aws_iam_role" "getrole"{
  name=var.iamrole
}


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

resource "aws_security_group" "ecs-sg" {
  name="ecs-sg"
  vpc_id = var.vpc-id
  ingress {
      description = "inbound-traffic"
      from_port = "80"
      to_port = "80"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
      description = "outbound-traffic"
      from_port = "0"
      to_port= "0"
      protocol = "-1" 
      cidr_blocks = ["0.0.0.0/0"]
  }
}




