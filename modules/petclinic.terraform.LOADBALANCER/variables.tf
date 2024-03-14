variable "lb-name" {
    type=string 
    description = "app-loadbalancer-name"
  
}

variable "lb-type"{
    type=string 
    description = "load-balancer-type"
}

variable "vpc-id" {
  type=string 
  description = "vpc-id"
}

variable "sgid" {
  type=string 
  description="security-group-id"  
}