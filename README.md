
# Azure Load Balancer Setup with Terraform

This Terraform configuration sets up an Azure Load Balancer (LB) to distribute traffic among multiple virtual machines (VMs) in a backend pool. It includes configurations for network interfaces, public IP, load balancer, backend pool, health probe, rules, NAT rules, DNS setup, and more.

## Prerequisites

- Azure CLI installed and configured
- Terraform installed (version >= 0.13)
- Azure subscription

## Getting Started

1. Clone this repository:

   ```
   git clone <repository_url>
   cd <repository_directory>
   ```

2. Initialize Terraform:

   ```
   terraform init
   ```

3. Modify `variables.tf` with your specific configurations.

4. Review and apply the Terraform plan:

   ```
   terraform plan
   terraform apply
   ```

## Configuration Details

### Network Interfaces

Defines network interfaces for VMs with dynamic private IP allocation.

### Public IP

Static allocation method for the Load Balancer's public IP address.

### Load Balancer

Standard SKU load balancer with a frontend IP configuration using the allocated public IP.

### Backend Address Pool

Defines a backend pool with VMs' private IP addresses.

### Health Probe

TCP probe to check VMs' SSH availability on port 22.

### Load Balancer Rule

TCP rule to forward traffic from port 80 on the Load Balancer to port 80 on backend VMs.

### NAT Rule

Allows SSH access (port 22) to backend VMs through a range of frontend ports (2200-2300).

### DNS Setup

Creates a DNS zone and A record to point your domain (`www.rimtest.com`) to the Load Balancer's public IP.

## Outputs

- DNS zone name servers for configuring your domain's DNS settings.

## Cleanup

To avoid unnecessary charges, destroy the Terraform-managed resources:

```
terraform destroy
```

---

This README provides a structured overview of your Terraform configuration for setting up an Azure Load Balancer. Adjust the content based on your specific project details and requirements.
