terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_user             = var.proxmox_user
  pm_password         = var.proxmox_password
  pm_tls_insecure     = var.proxmox_tls_insecure
  pm_parallel         = 2
  pm_timeout          = 600
}

# Multiple containers using for_each - simple container creation
resource "proxmox_lxc" "ubuntu_containers" {
  for_each = var.containers

  target_node     = var.proxmox_node
  hostname        = each.value.hostname
  ostemplate      = var.ubuntu_template
  password        = each.value.password
  unprivileged    = true
  
  # Container ID from configuration
  vmid = each.value.vmid

  # Root filesystem - different sizes per container
  rootfs {
    storage = var.storage_pool
    size    = each.value.disk_size
  }

  # CPU and Memory - different per container
  cores  = each.value.cpu_cores
  memory = each.value.memory_mb

  # Network configuration - different IPs per container
  network {
    name   = "eth0"
    bridge = var.network_bridge
    ip     = each.value.ip_address
    gw     = each.value.gateway != "" ? each.value.gateway : var.gateway_ip
  }

  # SSH key (optional)
  ssh_public_keys = var.ssh_public_keys

  # Start the container after creation
  start = each.value.auto_start

  # Features - can be different per container
  features {
    nesting = each.value.enable_nesting
  }

  # Tags for organization - different per container
  tags = each.value.tags
} 