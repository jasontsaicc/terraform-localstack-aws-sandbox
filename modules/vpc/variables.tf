variable "project_name" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "subnet_cidr" {
    type = list(string)
  
}

variable "private_subnet_cidrs" {
    type = list(string)
  
}

variable "public_subnet_cidrs" {
    type = list(string)
  
}