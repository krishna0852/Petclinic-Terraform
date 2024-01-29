module "vpc" {
  source = "./modules/petclinic.terraform.VPC"
   vpc_cidr_range = "10.9.0.0/24"
}

module "subnet" {
  source="./modules/petclinic.terraform.SUBNET"  

  vpc-id = module.vpc.getvpc-id
  pblcsbnt-config = {
  pblc-a = {
    availability_zone = "ap-southeast-2a"
    cidr_block        = "10.9.0.0/26"
    name              = "pblc-A"
  }
   

}
prvtsbnt-config = {
  prvt-a = {
    availability_zone = "ap-southeast-2b"
    cidr_block        = "10.9.0.128/26"
     name              = "prvt-A"
  }
   
}


}

module "alb" {
  source = "./modules/petclinic.terraform.LOADBALANCER"
  lb-name = "petclinic-lb"
  lb-type = "application"
  vpc-id = module.vpc.getvpc-id
  sgid = module.subnet.security-id
  depends_on = [ module.vpc, module.subnet ]
}

module "IAM" {
  source="./modules/petclinic.terraform.IAM"
  #depends_on = [ module.ECS ]
}

module "ECS" {
    source="./modules/petclinic.terraform.ECS"
    cluster_name = "dev-petclinic-cluster"
    family-name = "petclinic-web"
    iamrole = "ecs-execution-role"
    #ecs-execution-role
    sgid = module.subnet.security-id
    vpc-id = module.vpc.getvpc-id
    tgroup_arn = module.alb.tgroup_arn
    depends_on = [ module.vpc, module.subnet, module.IAM, module.alb] # don't change this line
}


module "ECR" {
  source="./modules/petclinic.terraform.ECR"
  ecr-name = ["repo"]

  tags={
    "environment" ="dev"
  }

  
}






# module "EC2" {
#   source="./modules/petclinic.terraform.EC2"
# }



