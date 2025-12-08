variable "project_name" {}
variable "env" {}
variable "aws_region" {}

variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "alb_security_group_id" {}
variable "target_group_arn" {}

variable "image_url" {
  description = "The Docker image to run"
}

variable "cpu" {
  description = "Fargate CPU units (256 = 0.25 vCPU)"
  default     = 256
}

variable "memory" {
  description = "Fargate Memory (512 = 0.5 GB)"
  default     = 512
}

variable "app_count" {
  description = "Number of Docker containers to run"
  default     = 1
}