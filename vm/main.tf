data "azurerm_resource_group" "vm" {
  name = var.resource_group
}

data "azurerm_subnet" "vm" {
  name                 = var.subnet
  virtual_network_name = var.virtual_network
  resource_group_name  = data.azurerm_resource_group.vm.name
}

resource "azurerm_public_ip" "vm" {
  name                = "${var.vmname}-pip"
  location            = data.azurerm_resource_group.vm.location
  resource_group_name = data.azurerm_resource_group.vm.name
  tags                = var.tags

  allocation_method = "Static"
  //domain_name_label     =  var.vmname
}

resource "azurerm_network_interface" "vm" {
  name                = "${var.vmname}-nic"
  location            = data.azurerm_resource_group.vm.location
  resource_group_name = data.azurerm_resource_group.vm.name
  tags                = var.tags
  //network_security_group_id     =  azurerm_network_security_group.vm.id

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                          = var.vmname
  location                      = data.azurerm_resource_group.vm.location
  resource_group_name           = data.azurerm_resource_group.vm.name
  tags                          = var.tags
  vm_size                       = "Standard_DS1_v2"
  network_interface_ids         = ["${azurerm_network_interface.vm.id}"]
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vmname}-os"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = var.vmname
    admin_username = var.ssh_user
    // TODO: This custom data line isn't working
    //custom_data    = "sudo apt-get update && sudo apt-get install -yq aptitude tree jq && sudo apt-get dist-upgrade -yq"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.ssh_user}/.ssh/authorized_keys"
      key_data = file(var.ssh_pub_key_file)
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

/*
resource "azurerm_virtual_machine_extension" "monitor-agent" {
  name                          = "${var.vmname}-monitor"
  location                      =  data.azurerm_resource_group.vm.location
  resource_group_name           =  data.azurerm_resource_group.vm.name
  tags                          =  var.tags

  virtual_machine_name          =  azurerm_virtual_machine.vm.name
  publisher                     = "Microsoft.EnterpriseCloud.Monitoring"
  type                          = "OmsAgentForLinux"
  type_handler_version          = "1.7"
  auto_upgrade_minor_version    = true

  settings = <<SETTINGS
        {
          "workspaceId": "${azurerm_log_analytics_workspace.vm.workspace_id}"
        }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
        {
          "workspaceKey": "${azurerm_log_analytics_workspace.vm.secondary_shared_key}"
        }
PROTECTED_SETTINGS
}
*/

