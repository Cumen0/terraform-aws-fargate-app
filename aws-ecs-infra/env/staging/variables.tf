variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  sensitive   = true
}

variable "default_tags" {
  description = "A map of default tags to apply to all resources."
  type        = map(string)
}

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "env" {
  description = "The deployment environment."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks."
  type        = list(string)
}
