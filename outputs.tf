# Outputs for multiple containers
output "container_details" {
  description = "Details of all created containers"
  value = {
    for name, container in proxmox_lxc.ubuntu_containers : name => {
      id       = container.vmid
      hostname = container.hostname
      ip       = container.network[0].ip
      status   = container.start ? "running" : "stopped"
      node     = container.target_node
      cores    = container.cores
      memory   = container.memory
      disk     = container.rootfs[0].size
      tags     = container.tags
    }
  }
}

output "container_ips" {
  description = "IP addresses of all containers"
  value = {
    for name, container in proxmox_lxc.ubuntu_containers : name => container.network[0].ip
  }
}

output "container_ssh_commands" {
  description = "SSH commands to connect to each container"
  value = {
    for name, container in proxmox_lxc.ubuntu_containers : name => 
      container.network[0].ip != "dhcp" ? "ssh root@${split("/", container.network[0].ip)[0]}" : "ssh root@<dhcp-ip>"
  }
} 