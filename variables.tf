// Proxmox Connection Variables
variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g., https://192.168.1.100:8006/api2/json)"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox username (e.g., root@pam or terraform@pve!token)"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox password or API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification (set to true for self-signed certificates)"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Proxmox node name where the container will be created"
  type        = string
}

// Template and shared settings
variable "ubuntu_template" {
  description = "Ubuntu template name (e.g., local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst)"
  type        = string
}

variable "storage_pool" {
  description = "Storage pool name (e.g., local-lvm, local)"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge (e.g., vmbr0)"
  type        = string
  default     = "vmbr0"
}

variable "gateway_ip" {
  description = "Gateway IP address (only needed if using static IP)"
  type        = string
  default     = ""
}

variable "ssh_public_keys" {
  description = "SSH public keys to add to the container (newline separated)"
  type        = string
  default     = ""
}

// Multiple Containers Configuration
variable "containers" {
  description = "Map of containers to create with their configurations"
  type = map(object({
    hostname       = string
    password       = string
    vmid          = number
    cpu_cores     = number
    memory_mb     = number
    disk_size     = string
    ip_address    = string
    gateway       = string
    auto_start    = bool
    enable_nesting = bool
    tags          = string
  }))
  default = {}
} 