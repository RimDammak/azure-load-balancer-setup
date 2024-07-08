
variable "prefix" {
  description = "Prefix"
  type        = string
  default     = "k8s-cluster"
}
variable "location" {
  type    = string
  default = "westeurope"

}

variable "nodecount" {
  default     = 2
  description = "Number of virtual machines"
}
variable "username" {
  description = "Admin username for the virtual machines"
  type        = string
  default     = "rim"
}

variable "password" {
  description = "Admin password for the virtual machines"
  type        = string
  default     = "Rim1235"
}
