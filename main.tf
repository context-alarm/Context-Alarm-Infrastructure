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

# Multiple containers using for_each
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

  # Wait for container to be ready
  connection {
    type     = "ssh"
    user     = "root"
    password = each.value.password
    host     = split("/", each.value.ip_address)[0]  # Extract IP without subnet
    timeout  = "5m"
  }

  # Install Docker using remote-exec provisioner
  provisioner "remote-exec" {
    inline = [
      # Wait for container to be fully ready
      "while ! systemctl is-active --quiet ssh; do sleep 2; done",
      "sleep 10",  # Additional wait for system to stabilize
      
      # Update package list
      "apt-get update",
      
      # Install prerequisites
      "apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common",
      
      # Add Docker GPG key
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      
      # Add Docker repository
      "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' > /etc/apt/sources.list.d/docker.list",
      
      # Update package list with Docker repo
      "apt-get update",
      
      # Install Docker
      "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      
      # Enable and start Docker
      "systemctl enable docker",
      "systemctl start docker",
      
      # Install Docker Compose standalone
      "DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '\"tag_name\": \"\\K.*?(?=\")')",
      "curl -L \"https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "chmod +x /usr/local/bin/docker-compose",
      
      # Test Docker installation
      "docker --version",
      "docker compose version",
      "docker run --rm hello-world",
      
      # Create a marker file to indicate Docker is installed
      "echo 'Docker installed by Terraform on $(date)' > /opt/docker-installed.txt"
    ]
  }
} 