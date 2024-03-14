dev_vpc_cidr_range = "10.9.0.0/24"
pblcsbnt-config = {
  pblc-a = {
    availability_zone = "ap-southeast-2a"
    cidr_block        = "10.9.0.0/26"
    name              = "pblc-A"
  }

prvtsbnt-config = {
  prvt-a = {
    availability_zone = "ap-southeast-2b"
    cidr_block        = "10.9.0.128/26"
     name              = "prvt-A"
  }
   
}
dev_lb-name = "petclinic-lb"
dev_lb-type = "application"
dev_cluster_name = "dev-petclinic-cluster"
dev_family-name = "petclinic-web"
dev_iamrole = "ecs-execution-role"
dev_ecr-name = ["repo"]
dev_environment ="dev"
dev_hosted-zone-name="devopshandson3.cloud"
dev_environment="dev"
dev_record-type="A"
dev_ttl="300"
dev_app-name = "petapp-dev"