resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location

}
# Create virtual network 
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-virtual-network"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
# Create subnet

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = ["10.10.5.0/24"]
  virtual_network_name = azurerm_virtual_network.main.name


}

# Create Network Security Group and rule



resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-network-security-group"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Outbound-Allow-Established"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow established connections"
  }

  # Inbound rule - SSH access from specified sources
  security_rule {
    name                       = "Inbound-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*" # Replace with your specific IP or CIDR range
    destination_address_prefix = "*"
    description                = "Allow SSH access from specific IP/CIDR"
  }


}
// Network interface security group associations
resource "azurerm_network_interface_security_group_association" "nsg-nic1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.main.id
}
// Network interface security group associations
resource "azurerm_network_interface_security_group_association" "nsg-nic2" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.main.id
}
