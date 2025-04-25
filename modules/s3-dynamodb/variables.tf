variable "bucket" {
  description = "The name of the S3 bucket"
  type        = string
<<<<<<< HEAD
  default     = "class38-terraform-backend-bucket"
=======
  default     = "dominion-terraform-backend-bucket"
>>>>>>> d58be69 (first commit)
}

variable "table" {
  description = "The name of the DynamoDB table"
  type        = string
  default     = "terraform-state-locking"
}

variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-west-2"
}
