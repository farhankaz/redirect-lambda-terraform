variable "function_name" {
  default = "fk_acclaim_302"
}

variable "vpc_id" {
  description = "The id of the vpc for alb."
  default     = "vpc-9820f6fe"
}

variable "subnets" {
  default = ["subnet-4f21fc15", "subnet-ff3bba99"]
}

variable "ssl_certificate_arn" {
  default = "arn:aws:acm:us-west-1:860076585994:certificate/bbeb05c7-5ffb-43df-a94e-a670694407bc"
}