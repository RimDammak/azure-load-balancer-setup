# VMs
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.prefix}-vm1"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = "Standard_A2_v2"
  # size                            = "Standard_D2_v2"
  
  disable_password_authentication = false
  timeouts {
    create = "10m"
    delete = "30m"
  }

  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  admin_username = var.username
  admin_password = var.password
  admin_ssh_key {
    username   = var.username 
    public_key = file("/../.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.prefix}-osdisk-1"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.username # Ensure this matches the admin username
    public_key = file("/../.ssh/id_rsa.pub")
  }

  connection {
    type        = "ssh"
    user        = var.username
    private_key = file("/../.ssh/id_rsa")
    host        = azurerm_public_ip.lb_public_ip.ip_address  # Use the IP of the Load Balancer for SSH access
    timeout     = "4m"
    agent       = false

  }
  depends_on = [
    azurerm_subnet.main, azurerm_network_interface.nic1
  ]
}

# trunk-ignore(git-diff-check/error)


# VMs
resource "azurerm_linux_virtual_machine" "vm2" {
  name                            = "${var.prefix}-vm2"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = "Standard_A2_v2"
  # size                            = "Standard_D2_v2"
  
  disable_password_authentication = false
  timeouts {
    create = "10m"
    delete = "30m"
  }

  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]

  admin_username = var.username
  admin_password = var.password
  admin_ssh_key {
    username   = var.username 
    public_key = file("/../.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.prefix}-osdisk-2"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.username # Ensure this matches the admin username
    public_key = file("/../.ssh/id_rsa.pub")
  }

  connection {
    type        = "ssh"
    user        = var.username
    private_key = file("/../.ssh/id_rsa")
    host        = azurerm_public_ip.lb_public_ip.ip_address  # Use the IP of the Load Balancer for SSH access
    timeout     = "4m"
    agent       = false

  }
  depends_on = [
    azurerm_subnet.main, azurerm_network_interface.nic2
  ]
}

# trunk-ignore(git-diff-check/error)


