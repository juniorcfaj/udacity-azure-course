variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "project-one"
  type = string
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "East US"
}

variable "vm_count" {
  description = "How many VMs do you need?"
  type = number
  default = 2
}

variable "user" {
  description = "Set your username"
  type = string
  default = "adminuser"
}

variable "password" {
  description = "Set your password"
  type = string
  default = "P@ssw0rd1234!"
}