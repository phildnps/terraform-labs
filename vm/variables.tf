variable "resource_group" {
  type = string
}

variable "vmname" {
  default = "test"
}

variable "virtual_network" {
  type = string
}

variable "subnet" {
  default = "default"
}

variable "tags" {
  type = map
}

variable "ssh_user" {
  type = string
}

variable "ssh_pub_key_file" {
  default = "~/.ssh/id_rsa.pub"
}