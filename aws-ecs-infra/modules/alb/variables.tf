variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate"
  type        = string
  default     = null
}

variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}