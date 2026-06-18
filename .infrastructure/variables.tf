variable "region" {
  description = "AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name (e.g. demo, staging, prod)"
}

variable "function_name" {
  description = "Base name used for ECS cluster, service, task, and ECR repository"
  default     = "react-zustand-django-template"
}

variable "app_name" {
  description = "Short name for resources with strict name limits (ALB, target group: max 32 chars)"
  default     = "zustand-api"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "container_port" {
  description = "Port the Django container listens on"
  default     = 8080
}

variable "task_cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)"
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MB"
  default     = 512
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  default     = 1
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention period in days"
  default     = 30
}

variable "frontend_bucket_name" {
  description = "Base name for the S3 bucket hosting the React frontend"
  default     = "template-frontend"
}

variable "allowed_origins" {
  description = "List of allowed CORS origins (API Gateway CORS + Django CORS_ALLOWED_ORIGINS)"
  type        = list(string)
  # WARNING: "*" allows all origins. Restrict this to your frontend domain before going to prod.
  default = ["*"]
}

variable "allowed_hosts" {
  description = "Comma-separated ALLOWED_HOSTS for Django (set to ALB DNS name in production)"
  default     = "*"
}

variable "django_secret_key" {
  description = "Django SECRET_KEY — treat as a secret, never commit to version control"
  sensitive   = true
}

variable "about_message" {
  description = "Value returned by the /about endpoint"
  default     = "Template API v0.0.1"
}
