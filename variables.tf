variable "name" {
  type        = string
  description = "EFS volume name to create"
}
variable "kms_arn" {
  type        = string
  description = "KMS ARN to use"
}
variable "vpc" {
  type = object({
    id         = string
    subnet_ids = list(string)
    cidr       = string
  })
  description = "VPC config for volume"

}
variable "users" {
  type = map(object({
    gid  = number
    uid  = number
    path = string
  }))
  description = "User config for volume"
}
variable "context" {
  type = object({
    organization = string
    environment  = string
    account      = string
    product      = string
    tags         = map(string)
  })
  description = "Default environmental context"
}
