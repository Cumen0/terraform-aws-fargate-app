# AWS ECS Fargate Todo Application

![Build Status](https://github.com/Cumen0/terraform-aws-fargate/actions/workflows/deploy.yml/badge.svg)

A production-ready, cloud-native To-Do application deployed on AWS ECS Fargate with infrastructure-as-code using Terraform. This monorepo contains both the application code and the complete infrastructure definition.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Infrastructure Deployment](#infrastructure-deployment)
- [Application Development](#application-development)
- [CI/CD Pipeline](#cicd-pipeline)
- [Configuration](#configuration)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🎯 Overview

This project demonstrates a modern, serverless-first approach to deploying web applications on AWS:

- **Backend**: Flask application with DynamoDB for data persistence
- **Infrastructure**: Fully automated AWS infrastructure using Terraform
- **Deployment**: AWS ECS Fargate with Application Load Balancer
- **CI/CD**: GitHub Actions for automated testing and deployment
- **Security**: IAM roles for authentication, no hardcoded credentials

### 🌐 Live Demo

**👉 [https://volodymyr-diadechko.online](https://volodymyr-diadechko.online)**

Experience the application live! The demo is running on AWS ECS Fargate with production-grade infrastructure, secured with HTTPS via ACM certificate, and accessible through a custom domain.

**Domain Configuration:**

- **Domain**: `volodymyr-diadechko.online`
- **SSL/TLS**: Managed by AWS Certificate Manager (ACM)
- **HTTPS**: Enabled and enforced
- **DNS**: Configured via Route 53 (or your DNS provider)

### Key Features

- ✅ Fully automated infrastructure provisioning
- ✅ Serverless container deployment (Fargate)
- ✅ Auto-scaling and high availability
- ✅ HTTPS enabled with ACM certificates
- ✅ Secure IAM-based authentication
- ✅ Modern, responsive web UI
- ✅ Production-ready Docker configuration
- ✅ Comprehensive CI/CD pipeline

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Internet Users                           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│         Application Load Balancer (ALB)                     │
│         - HTTPS (ACM Certificate)                           │
│         - Health Checks                                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              ECS Fargate Service                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Task 1     │  │   Task 2     │  │   Task N     │       │
│  │  (Flask App) │  │  (Flask App) │  │  (Flask App) │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                 │                  │              │
│         └─────────────────┴──────────────────┘              │
│                           │                                 │
│                    IAM Task Role                            │
└────────────────────────────┼────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    DynamoDB Table                           │
│                    (Task Storage)                           │
└─────────────────────────────────────────────────────────────┘
```

### Infrastructure Components

- **VPC**: Custom VPC with public and private subnets across multiple AZs
- **ALB**: Application Load Balancer with HTTPS termination
- **ECS Fargate**: Serverless container orchestration
- **DynamoDB**: NoSQL database for task storage
- **ECR**: Container registry for Docker images
- **IAM**: Task roles for secure AWS service access
- **ACM**: SSL/TLS certificates for HTTPS

## 📁 Project Structure

```
monorepo/
├── .github/
│   └── workflows/
│       └── deploy.yml            # CI/CD pipeline
├── aws-ecs-infra/
│   ├── modules/                  # Reusable Terraform modules
│   │   ├── alb/                  # Application Load Balancer
│   │   ├── dynamodb/             # DynamoDB table
│   │   ├── ecr/                  # ECR repository
│   │   ├── ecs/                  # ECS cluster and service
│   │   └── network/              # VPC and networking
│   └── env/
│       └── staging/              # Staging environment
│           ├── main.tf           # Main configuration
│           ├── variables.tf      # Variable definitions
│           ├── outputs.tf        # Output values
│           ├── providers.tf      # Provider configuration
│           └── terraform.tfvars  # Variable values (not in git)
├── todo-app/
│   └── app/
│       ├── app.py                # Flask application
│       ├── Dockerfile            # Container definition
│       ├── requirements.txt      # Python dependencies
│       └── templates/
│           └── index.html        # Frontend template
└── README.md
```

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Terraform** >= 1.0
- **AWS CLI** >= 2.0
- **Docker** >= 20.10
- **Python** >= 3.11 (for local development)
- **AWS Account** with appropriate permissions
- **GitHub Account** (for CI/CD)

### AWS Permissions Required

Your AWS credentials need permissions for:

- EC2 (VPC, subnets, security groups)
- ECS (clusters, services, task definitions)
- ECR (repositories, image push/pull)
- ALB (load balancers, target groups, listeners)
- DynamoDB (tables, IAM policies)
- IAM (roles, policies)
- ACM (certificates)
- S3 (Terraform state backend)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd monorepo
```

### 2. Configure AWS Credentials

```bash
aws configure
# Or use environment variables:
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=your-region
```

### 3. Set Up Terraform Backend

The Terraform state is stored in S3. Ensure the S3 bucket and DynamoDB table for state locking exist:

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://your-terraform-state-bucket

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 4. Configure Terraform Variables

Create `aws-ecs-infra/env/staging/terraform.tfvars`:

```hcl
aws_region = "___"
default_tags = {
  Owner        = "___"
  Project_Name = "___"
  Made_By      = "___"
}
project_name = "___"
env          = "___"
vpc_cidr             = "___"
public_subnet_cidrs  = ["___", "___"]
private_subnet_cidrs = ["___", "___"]
terraform_state_bucket = "___"
locks_table = "___"
domain_name = "___"
```

## 🏭 Infrastructure Deployment

### Manual Deployment

1. **Initialize Terraform**:

   ```bash
   cd aws-ecs-infra/env/staging
   terraform init
   ```

2. **Review the plan**:

   ```bash
   terraform plan
   ```

3. **Apply the infrastructure**:

   ```bash
   terraform apply
   ```

4. **Get outputs**:
   ```bash
   terraform output
   ```

### Destroy Infrastructure

```bash
terraform destroy
```
⚠️ **Warning**: This will delete all resources. Use with caution!

## 💻 Application Development

### Local Development

1. **Install dependencies**:

   ```bash
   cd todo-app/app
   pip install -r requirements.txt
   ```

2. **Set environment variables**:

   ```bash
   export DYNAMODB_TABLE=your-table-name
   export AWS_DEFAULT_REGION=your-region
   ```

3. **Run the application**:

   ```bash
   python app.py
   ```

4. **Access the app**: http://localhost:5000

### Building Docker Image

```bash
cd todo-app/app
docker build -t todo-app:latest .
docker run -p 80:5000 -e DYNAMODB_TABLE=your-table-name todo-app:latest
```

### Testing Locally with Docker Compose

Create `docker-compose.yml`:

```yaml
version: "3.8"
services:
  app:
    build: .
    ports:
      - "80:5000"
    environment:
      - DYNAMODB_TABLE=local-todo-table
      - AWS_DEFAULT_REGION=your-region
    volumes:
      - ~/.aws:/root/.aws:ro
```

## 🔄 CI/CD Pipeline

The project includes a comprehensive GitHub Actions workflow that:

1. ✅ Runs Python dependency checks
2. ✅ Executes unit tests (if present)
3. ✅ Lints Dockerfile with Hadolint
4. ✅ Formats and validates Terraform code
5. ✅ Plans and applies infrastructure changes
6. ✅ Builds and pushes Docker images to ECR
7. ✅ Updates ECS service with new deployment

### Setting Up GitHub Secrets

Configure the following secrets in GitHub:

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `TF_VARS_STAGING`: Complete content of `terraform.tfvars` file (multiline)

### Pipeline Triggers

The pipeline automatically runs on:

- Push to `main` branch
- Manual workflow dispatch (optional)

### Viewing Pipeline Status

Check the Actions tab in your GitHub repository to monitor deployment progress.

## ⚙️ Configuration

### Environment Variables

The application uses the following environment variables:

| Variable             | Description         | Default          |
| -------------------- | ------------------- | ---------------- |
| `DYNAMODB_TABLE`     | DynamoDB table name | `todo-table-dev` |
| `AWS_DEFAULT_REGION` | AWS region          | `your-region`    |

### DynamoDB Table Schema

```json
{
  "id": "uuid-string",
  "task": "Task description",
  "status": "todo|done",
  "created_at": "ISO-8601 timestamp"
}
```

### Domain Configuration

The application is configured to use a custom domain with HTTPS:

- **Production Domain**: `volodymyr-diadechko.online`
- **SSL Certificate**: Managed by AWS Certificate Manager (ACM)
- **HTTPS**: Automatically enabled and enforced

#### Setting Up Your Own Domain

1. **Request ACM Certificate**:

   - The certificate is automatically requested in Terraform
   - Ensure your domain is validated in ACM (DNS or email validation)

2. **Configure DNS**:

   - Point your domain's A record to the ALB DNS name
   - Get ALB DNS from Terraform outputs: `terraform output alb_dns_name`
   - Or use Route 53 alias record pointing to the ALB

3. **Update Terraform Variables**:

   ```hcl
   domain_name = "your-domain"
   ```

4. **Verify HTTPS**:
   - After deployment, access your application via `https://your-domain`
   - The ALB automatically redirects HTTP to HTTPS

### Terraform Variables

See `aws-ecs-infra/env/staging/variables.tf` for all available variables.

## 🔒 Security

### Best Practices Implemented

- ✅ **No hardcoded credentials**: Uses IAM Task Roles
- ✅ **HTTPS only**: ACM certificates for SSL/TLS
- ✅ **Private subnets**: ECS tasks run in private subnets
- ✅ **Security groups**: Least privilege network access
- ✅ **IAM roles**: Minimal required permissions
- ✅ **Secrets management**: Terraform variables in GitHub Secrets
- ✅ **Non-root containers**: Docker runs as non-root user

### IAM Permissions

The ECS Task Role requires:

- `dynamodb:PutItem`
- `dynamodb:GetItem`
- `dynamodb:UpdateItem`
- `dynamodb:DeleteItem`
- `dynamodb:Scan`

### Network Security

- ALB in public subnets (internet-facing)
- ECS tasks in private subnets (no direct internet access)
- Security groups restrict traffic to necessary ports only

## 🐛 Troubleshooting

### Common Issues

#### Terraform State Lock

**Problem**: `Error acquiring the state lock`

**Solution**:

```bash
# Check who has the lock
aws dynamodb get-item \
  --table-name terraform-locks \
  --key '{"LockID": {"S": "your-lock-id"}}'

# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

#### ECS Service Not Starting

**Problem**: Tasks fail to start

**Solution**:

1. Check CloudWatch Logs for errors
2. Verify IAM Task Role permissions
3. Ensure DynamoDB table exists
4. Check security group rules

#### Docker Build Fails

**Problem**: Build errors in CI/CD

**Solution**:

- Verify Dockerfile syntax
- Check base image availability
- Review build logs in GitHub Actions

#### Application Can't Connect to DynamoDB

**Problem**: `ResourceNotFoundException` or access denied

**Solution**:

1. Verify table name in environment variable
2. Check IAM Task Role has DynamoDB permissions
3. Ensure table exists in the same region

### Debugging Commands

```bash
# Check ECS service status
aws ecs describe-services \
  --cluster <cluster-name> \
  --services <service-name>

# View CloudWatch logs
aws logs tail /ecs/<log-group-name> --follow

# Check task definition
aws ecs describe-task-definition \
  --task-definition <task-definition-name>

# Test DynamoDB connection
aws dynamodb scan --table-name <table-name>
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- **Python**: Follow PEP 8
- **Terraform**: Use `terraform fmt` before committing
- **Dockerfile**: Follow best practices (multi-stage builds, non-root user)

## 📄 License

This project is licensed under the MIT License.

## 👤 Author

**Volodymyr Diadechko**

- Project: AWS ECS Infrastructure with Todo Application
- Infrastructure: Terraform
- Deployment: AWS Fargate

## 🙏 Acknowledgments

- AWS for providing excellent cloud services
- HashiCorp for Terraform
- Flask and Python communities

---

**Note**: This is a production-ready template. Always review and customize security settings, resource sizes, and configurations according to your specific requirements and compliance needs.
