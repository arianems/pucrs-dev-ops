variable "aws_region"  { default = "us-east-2" }
variable "app_name"    { default = "blazor-app" }
variable "subnet_ids"  { type = list(string) }
variable "vpc_id"      { type = string }