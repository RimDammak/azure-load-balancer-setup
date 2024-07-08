resource "azurerm_public_ip" "ansible" {
  name                = "${var.prefix}-public-ip-vm-ansible"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}
# Network interfaces
resource "azurerm_network_interface" "ansible" {
  name                = "${var.prefix}-interface-vm-ansible"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}-interface-vm-ansible-config"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ansible.id
  }
}


resource "azurerm_linux_virtual_machine" "ansible" {
  name                            = "${var.prefix}-ansible-vm"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = "Standard_D1_v2"
  disable_password_authentication = false
  timeouts {
    create = "10m"
    delete = "30m"
  }

  network_interface_ids = [azurerm_network_interface.ansible.id]

  admin_username = var.username
  admin_password = var.password
  admin_ssh_key {
    username   = var.username 
    public_key = file("/../.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.prefix}-osdisk-ansible"
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
    host        = azurerm_public_ip.ansible.ip_address  # Use the IP of the Load Balancer for SSH access
    timeout     = "4m"
    agent       = false

  }
}