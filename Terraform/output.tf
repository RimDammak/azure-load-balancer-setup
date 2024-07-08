output "ssh_commands_ansible" {
  value = "ssh ${var.username}@${azurerm_public_ip.ansible.ip_address}"
}

output "ssh_commands_vms" {
  value = [
    for i in range(var.nodecount) : "ssh ${var.username}@${azurerm_public_ip.lb_public_ip.ip_address} -p ${2200 + i}"
  ]
}


