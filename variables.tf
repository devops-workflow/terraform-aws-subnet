
// Standard Variables

variable "name" {
  description = "Name"
  default = "private"
}
variable "environment" {
  description = "Environment (ex: dev, qa, stage, prod)"
}
variable "namespaced" {
  description = "Namespace all resources (prefixed with the environment)?"
  default     = true
}
variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

// Module specific Variables

variable "cidrs" {
  description = "List of VPC CIDR blocks"
  default     = []
}
variable "azs" {
  description = "List of availability zones"
  default     = []
}
variable "vpc_id" {
  description = "VPC id"
}
variable "igw_id" {
  description = "Internet gateway id"
}
variable "map_public_ip_on_launch" {
  description = "Should be true or false"
  default     = false
}
variable "cidr_add_bits" {
  description = "Number of bits to extend CIDR"
  default     = 0
}
variable "cidr_block" {
  description = "VPC CIDR block to create subnet in"
}
variable "subnet_offset" {
  description = "Offset to add to subnet number"
  default     = 0
}
variable "propagate_vgws" {
  description = "List of virtual gateways for propagation"
  type        = "list"
}
# REMOVE
variable "num_of_azs" {
  description = "Number of availability zones to use"
  default     = 2
}
