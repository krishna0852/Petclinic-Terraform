variable "cluster_name" {
  type=string 
  description="ecs-cluster-name"  
}

variable "family-name" {
  type=string
  description = "task-definition-filename"
}

# variable "container-definitions" {

#   type=map(object({
#     name=string
#     image=string 
#     cpu=number
#     memory=number 

#   }))
 
# }

# variable "iam-role-arn" {
#   type=string 
#   description = "iam-role-arn"
# }

variable "vpc-id" {
  type=string 
  description = "vpc-id"
  
}

variable "iamrole" {
  type=string
  description = "iam-role-name"
}

