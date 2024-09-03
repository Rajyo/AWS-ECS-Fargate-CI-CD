variable "vpc_cidr" {
  description = "VPC_CIDR_Range"
  type        = string
}

variable "public_subnets_cidr" {
  description = "Public_Subnets_CIDR_Range"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "Private_Subnets_CIDR_Range"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability_Zones"
  type        = list(string)
}

variable "AWS_REGION" {
  description = "AWS REGION"
  type        = string
}

variable "DOCKER_IMAGE" {
  description = "Docker Image"
  type        = string
}

variable "DOCKER_PORT" {
  description = "Docker Port"
  type        = number
}
