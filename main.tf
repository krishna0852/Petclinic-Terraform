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

module "ECS" {
    source="./modules/petclinic.terraform.ECS"
    cluster_name = "dev-petclinic-cluster"
}

# module "EC2" {
#   source="./modules/petclinic.terraform.EC2"
# }



