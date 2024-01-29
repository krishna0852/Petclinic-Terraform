variable "ecr-name" {
  #type= any
  type= list
  description="repository-name" 
}

variable "image_tag" {
  type=string
  default = "MUTABLE"
}

variable "tags" {
  type=map(string) 
  default ={}
}