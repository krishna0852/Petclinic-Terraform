locals {
  typesubnet=["public","private"]
  terraform=true

}


resource "aws_subnet" "public-subnets"{

    for_each=var.pblcsbnt-config
    vpc_id = var.vpc-id
    availability_zone = each.value.availability_zone
    cidr_block= each.value.cidr_block
    tags={
        Name=each.value.name
        executebyterraform="${local.terraform}"
    }
}

resource "aws_subnet" "private-subnets"{
    for_each=var.prvtsbnt-config
    vpc_id = var.vpc-id
    availability_zone =each.value.availability_zone
    cidr_block = each.value.cidr_block


    tags={
        Name=each.value.name
        executebyterraform="${local.terraform}"
    }
}


resource "aws_internet_gateway" "igw"{
    vpc_id = var.vpc-id

    tags={
        Name="${local.typesubnet[0]}-route"
        executebyterraform="${local.terraform}"
    }
}


resource "aws_eip" "elastic-ip"{
    domain = "vpc" 

    tags={
        Name="elastic-nat-gateway"
        executebyterraform="${local.terraform}"
    }
}

resource "aws_nat_gateway" "ngw"{
    for_each = var.pblcsbnt-config
    allocation_id = aws_eip.elastic-ip.id
    subnet_id = element([for subnet in aws_subnet.public-subnets : subnet.id], 0)
}

resource "aws_route_table" "pblc-route" {
    vpc_id = var.vpc-id


    route {
        cidr_block="0.0.0.0/0"
        gateway_id=aws_internet_gateway.igw.id 
    }
    tags={
        Name=""
        executebyterraform="${local.terraform}"
    }

}


resource "aws_route_table"  "prvt-route"{
    vpc_id = var.vpc-id
    for_each = var.prvtsbnt-config
    route {
        cidr_block="0.0.0.0/0"
        gateway_id=element([for ngw in aws_nat_gateway.ngw : ngw.id], 0)
        #aws_nat_gateway.ngw.gateway_id
        
    }

}

resource "aws_route_table_association" "public-association" {
  for_each = var.pblcsbnt-config
  subnet_id      = element([for subnet in aws_subnet.public-subnets : subnet.id],0)
  route_table_id = aws_route_table.pblc-route.id
}

resource "aws_route_table_association" "prvt-association" {
  for_each = var.prvtsbnt-config
  subnet_id      = element([for subnet in aws_subnet.private-subnets : subnet.id],0)
  route_table_id = element([for rtble in aws_route_table.prvt-route : rtble.id], 0)
}

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