variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "my_ip" {
  type        = string
  description = "Your public IPv4 CIDR, e.g. 203.0.113.10/32"
}

variable "app_port" {
  type = number
}