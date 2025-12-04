# terraform-aws-fargate

## Overview

This repository contains Terraform modules for deploying an AWS Fargate application with ECR (Elastic Container Registry), ECS, and networking components.

## How to Change the ECR Repository Name

The ECR repository name is configured via the `rep_name` variable in the ECR module. To change the repository name:

1. **When calling the ECR module**, pass the desired repository name as the `rep_name` variable:

   ```hcl
   module "ecr" {
     source   = "../../modules/ecr"
     rep_name = "your-repository-name"
   }
   ```

2. **Alternatively**, you can create a `terraform.tfvars` file in the environment directory (e.g., `env/staging/terraform.tfvars`) and set the variable there:

   ```hcl
   rep_name = "your-repository-name"
   ```

3. **Using command-line**, you can also pass the variable directly when running Terraform:

   ```bash
   terraform apply -var="rep_name=your-repository-name"
   ```

## Modules

- **ecr**: Manages the AWS ECR repository
- **ecs**: Manages the AWS ECS Fargate service
- **network**: Manages VPC, subnets, and other networking components
