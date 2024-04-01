variable "region" {
  default     = "us-east-1"
  description = "Region VM"
}

variable "ami_id" {
  default     = "ami-080e1f13689e07408"
  description = "AMI ID"
}

variable "instance_type" {
  default     = "t2.large"
  description = "Instance Type"
}

variable "key_name" {
  default     = "cicd"
  description = "Key Pair Name"
}