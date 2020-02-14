output "azure_ssh" {
  value = "ssh ${var.ssh_user}@${azurerm_public_ip.vm.ip_address}"
}

output "azure_public_ip" {
  value = azurerm_public_ip.vm.ip_address
}