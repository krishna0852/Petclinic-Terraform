variable "pblcsbnt-config" {
  type=map(object({
    availability_zone=string 
    cidr_block=string
    name=string

  }))
 
}


variable "prvtsbnt-config" {
  type=map(object({
    availability_zone=string 
    cidr_block=string
    name=string
    
  }))
}


variable "vpc-id" {
   type=string 
   description="vpc-id"  
}