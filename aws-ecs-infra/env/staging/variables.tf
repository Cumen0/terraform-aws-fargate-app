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

variable "terraform_state_bucket" {
  description = "The S3 bucket name for storing Terraform state."
  type        = string
}

variable "locks_table" {
  description = "The DynamoDB table name for Terraform state locking."
  type        = string
}

variable "domain_name" {
  description = "My domain name"
  type        = string
  default     = "volodymyr-diadechko.online"
}