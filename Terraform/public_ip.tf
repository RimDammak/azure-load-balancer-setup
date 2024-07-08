// Define network interfaces for VMs (example with static configuration for one VM)
resource "azurerm_network_interface" "nic1" {
  name                = "${var.prefix}-interface-vm1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}-interface-vm1-config"
    subnet_id                     = azurerm_subnet.main.id
        private_ip_address_allocation = "Dynamic"
  }
    depends_on = [
    azurerm_virtual_network.main,
    azurerm_subnet.main
  ]
}
resource "azurerm_network_interface" "nic2" {
  name                = "${var.prefix}-interface-vm2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}-interface-vm2-config"
    subnet_id                     = azurerm_subnet.main.id
        private_ip_address_allocation = "Dynamic"
  }
    depends_on = [
    azurerm_virtual_network.main,
    azurerm_subnet.main
  ]
}

// Define a public IP for the Load Balancer
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
// Define the Load Balancer
resource "azurerm_lb" "cluster_lb" {
  name                = "K8S-cluster-load-balancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
    sku                 = "Standard"


  frontend_ip_configuration {
    name                 = "Public-Address-Lb"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
    depends_on=[
    azurerm_public_ip.lb_public_ip
  ]
}

// Define the Load Balancer Backend Address Pool (example with static configuration for one VM)
resource "azurerm_lb_backend_address_pool" "back_end_pool" {
  loadbalancer_id = azurerm_lb.cluster_lb.id
  name            = "load-balancer-backend-pool"
    depends_on=[
    azurerm_lb.cluster_lb
  ]
}


resource "azurerm_lb_backend_address_pool_address" "appvm1_address" {
  name                    = "appvm1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.back_end_pool.id
  virtual_network_id      = azurerm_virtual_network.main.id
  ip_address              = azurerm_network_interface.nic1.private_ip_address
  depends_on=[
    azurerm_lb_backend_address_pool.back_end_pool
  ]
}

resource "azurerm_lb_backend_address_pool_address" "appvm2_address" {
  name                    = "appvm2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.back_end_pool.id
  virtual_network_id      = azurerm_virtual_network.main.id
  ip_address              = azurerm_network_interface.nic2.private_ip_address
  depends_on=[
    azurerm_lb_backend_address_pool.back_end_pool
  ]
}
resource "azurerm_lb_probe" "ProbeA" {
  loadbalancer_id     = azurerm_lb.cluster_lb.id
  name                = "is-ssh-running"
  port                = 22
  protocol            =  "Tcp"
  depends_on=[
    azurerm_lb.cluster_lb
  ]
}
resource "azurerm_lb_rule" "RuleA" {
  loadbalancer_id                = azurerm_lb.cluster_lb.id
  name                           = "RuleA"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "Public-Address-Lb"  # Update to match your frontend IP configuration

  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.back_end_pool.id]
  depends_on                     = [azurerm_lb.cluster_lb]
}

resource "azurerm_lb_nat_rule" "NATRuleA" {
  
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.cluster_lb.id
  name                           = "SSH-ACCESS"
  protocol                       = "Tcp"

  frontend_port_start            = 2200
  frontend_port_end              = 2300
  backend_port                   = 22
  backend_address_pool_id        = azurerm_lb_backend_address_pool.back_end_pool.id
  frontend_ip_configuration_name = "Public-Address-Lb"  # Update to match your frontend IP configuration
  depends_on                     = [azurerm_lb.cluster_lb]
}

resource "azurerm_dns_zone" "public_zone" {
  name                = "rimtest.com"
  resource_group_name = azurerm_resource_group.main.name
}
output "server_names"{
  value=azurerm_dns_zone.public_zone.name_servers
}
// Pointing the domain name to the load balancer
resource "azurerm_dns_a_record" "load_balancer_record" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public_zone.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 360
  records             = [azurerm_public_ip.lb_public_ip.ip_address  ]
}



























# // Associate the network interface of the VM with the load balancer backend address pool
# resource "azurerm_network_interface_backend_address_pool_association" "nic_lb_association" {
#   ip_configuration_name   = azurerm_network_interface.nic.name
#   network_interface_id    = azurerm_network_interface.nic.id
#   backend_address_pool_id = azurerm_lb_backend_address_pool.back_end_pool.id
# }

# // Define a probe to check the health of the VMs using SSH
# resource "azurerm_lb_probe" "lb_probe" {
#   loadbalancer_id = azurerm_lb.cluster_lb.id
#   name            = "ssh-running-probe"
#   port            = 22
# }

# // Define NAT rules for SSH access to VMs via the Load Balancer
# resource "azurerm_lb_nat_rule" "lb_nat_rule" {
#   resource_group_name             = azurerm_resource_group.main.name
#   loadbalancer_id                 = azurerm_lb.cluster_lb.id
#   name                            = "ssh-nat-rule"
#   protocol                        = "Tcp"
#   frontend_ip_configuration_name  = "Public-Address-Lb"
#   frontend_port_start             = 2200
#   frontend_port_end               = 2300
#   backend_port                    = 22
#   backend_address_pool_id         = azurerm_lb_backend_address_pool.back_end_pool.id
# }