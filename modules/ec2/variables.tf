variable "instance_count" {
  description = "Number of servers to deploy"
  type        = number
  default     = 4
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}


variable "instance_type" {
  description = "The type of instance to deploy"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key name for the instance"
  type        = string
  default     = "class38_demo_key"
}



