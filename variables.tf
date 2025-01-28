variable "aws_region" {
    type = string
    default = "ap-southeast-1"
}

variable "project_name" {
    type = string
    default = "localstack_aws_sandbox"
}

variable "vpc_cidr" {
    type = string
    default = "10.10.0.0/16"
}

variable "subnet_cidr" {
    type = list(string)
    default = [
        "10.10.1.0/24",
        "10.10.2.0/24"]  # subnet 2
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default = [
        "10.10.101.0/24",
        "10.10.102.0/24",
        ] 
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default = [
        "10.10.1.0/24",
        "10.10.2.0/24",
        ] 
}