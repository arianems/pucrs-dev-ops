variable "aws_region"  { default = "us-east-2" }
variable "app_name"    { default = "blazor-app" }
variable "subnet_ids"  { type = list(string) }
variable "vpc_id"      { type = string }
variable "aws_ecr_repository" { type = string }
variable "aws_ecs_cluster" { type = string }
variable "aws_ecs_service" { type = string }