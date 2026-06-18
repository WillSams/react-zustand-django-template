# Deploying Infrastructure with Terraform

This directory contains the Terraform configuration files to deploy the infrastructure for this template to AWS.

## Prerequisites

- Install Terraform [link](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Install AWS CLI [link](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
- Configure AWS CLI [link](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

## Infrastructure

Each environment provisions the following AWS resources:

- **ECR Repository** — stores the backend Docker image
- **VPC** — isolated network with two public subnets across two availability zones
- **Internet Gateway + Route Tables** — public internet access for subnets
- **Security Groups** — ALB (inbound 80/443) and ECS task (inbound from ALB only)
- **Application Load Balancer** — internet-facing, routes HTTP traffic to ECS tasks
- **ECS Cluster + Service** — Fargate tasks running the Django-Ninja ASGI app via uvicorn
- **ECS Task Definition** — container spec: image, port, env vars, CloudWatch logging
- **S3 Bucket** — hosts the built React frontend (private, versioned)
- **CloudFront Distribution** — CDN in front of S3 with SPA fallback (404 → index.html)
- **IAM Roles** — ECS task execution role (ECR + CloudWatch) and task role
- **CloudWatch Log Group** — ECS container logs with configurable retention

## Deploying Environments

Currently, the Terraform code is set up to deploy the **demo**, **staging**, and **production** environments. To deploy an environment, run the following commands:

```bash
cd .infrastructure
terraform init  # Initialize the Terraform configuration
terraform plan -var-file "environments/demo.tfvars" -var "django_secret_key=<secret>"
terraform apply -var-file "environments/demo.tfvars" -var "django_secret_key=<secret>"
```

`django_secret_key` is a sensitive variable and is never stored in `.tfvars` files. Pass it via `-var` or the `TF_VAR_django_secret_key` environment variable.

After apply, note the `alb_dns_name` output — set it as `ALLOWED_HOSTS` and `CORS_ALLOWED_ORIGINS` in your next `terraform apply` or directly in the ECS task definition.

Terraform allows for reproducible infrastructure deployments by using the same configuration files to deploy the same infrastructure in different environments. The `terraform apply` command will prompt you to confirm the deployment before proceeding.

Note: Additional environments can be added by creating a new `.tfvars` file in the `.infrastructure/environments` directory.

If you make changes to the Terraform configuration, run `terraform validate` to check for syntax errors. Before applying, run `terraform plan` to preview what will change.

## Cost Estimates

ECS Fargate, ALB, and CloudWatch Logs costs are based on usage. At low traffic, the primary costs are the ALB (~$16/month) and Fargate task runtime. S3 and CloudFront have generous free tiers. Use the [AWS Pricing Calculator](https://calculator.aws) to estimate costs for your expected workload.
