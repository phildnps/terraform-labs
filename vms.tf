module "vm1" {
  source          = "./vm"
  resource_group  = "core"
  virtual_network = "core"
  subnet          = "dev"
  vmname          = "vm1"
  tags            = var.tags
  ssh_user        = "phild"
}

module "vm2" {
  source          = "./vm"
  resource_group  = "core"
  virtual_network = "core"
  subnet          = "dev"
  vmname          = "vm2"
  tags            = var.tags
  ssh_user        = "phild"
}