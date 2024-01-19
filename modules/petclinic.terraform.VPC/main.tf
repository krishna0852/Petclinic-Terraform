locals {
  env="dev"
  projectName="petclinic"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_range

  tags = {
    Name="${local.env}-${local.projectName}"
    executebyterraform=true
  }
}