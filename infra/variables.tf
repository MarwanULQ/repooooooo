variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type        = string
  description = "Name of an existing EC2 key pair in AWS"
}

variable "my_ip" {
  type        = string
  description = "Your public IPv4 address with /32"
}

variable "app_port" {
  type = number
}