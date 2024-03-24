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
  lb-type = "network"
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
    repo_url = module.ECR.repo-url
    depends_on = [ module.vpc, module.subnet, module.IAM, module.alb, module.ECR] # don't change this line
}


module "ECR" {
  source="./modules/petclinic.terraform.ECR"
  ecr-name = "repo"

  tags={
    "environment" ="dev"
  }
}

module "r-53" {
  source="./modules/petclinic.terraform.ROUTE-53"
  hosted-zone-name="devopshandson3.cloud"
  environment="dev"
  record-type="A"
  app-name = "petapp-dev"
  alb-name=module.alb.alb-dns
  alb_zoneid = module.alb.zoneid
 # ttl = 300
}

# ECR PENDING 
# ROUTE-53 PENDING 
# CLOUD-FRONT-PENDING 

#PROPER VARIBALIZATION PENDING 

#PASS THIS FILE VALUES ALSO THROUGH VARIABLES 






# module "EC2" {
#   source="./modules/petclinic.terraform.EC2"
# }



