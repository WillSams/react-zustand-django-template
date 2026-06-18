locals {
  name_prefix = "${var.environment}-${var.function_name}"
  # ALB and target group names are capped at 32 chars; use app_name for those resources
  alb_name = "${var.environment}-${var.app_name}"
}
