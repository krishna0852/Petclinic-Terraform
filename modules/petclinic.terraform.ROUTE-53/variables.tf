variable "hosted-zone-name" {
   type=string 
   description = "give hosted-zone"
}

variable "environment" {
  type=string
  description = "give environment-specific-name"
}

variable "record-type" {
  type=string 
  description="give the record type"  
}

variable "ttl"{
    type=number
    description = "give the ttl"
}

variable "app-name" {
   type=string 
   description = "give the app-name"
}

variable "alb-name" {
  type=string
  description="give hte alb-name"

}

variable "alb_zoneid" {
  type=string 
  description="give the alb-zoneid"
}